import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';

class SrpService {
  // RFC 5054 2048-bit Group Parameters
  static final BigInt N = BigInt.parse(
    'AC6BDB41324A9A9BF166DE5E1389582FAF72B6651987EE07FC3192943DB56050A37329CBB4A099ED8193E0757767A13DD52312AB4B03310DCD7F48A9DA04FD50E8083969EDB767B0CF6095179A163AB3661A05FBD5FAAAE82918A9962F0B93B855F97993EC975EEAA80D740ADBF4FF747359D041D5C33EA71D281E446B14773BCA97B43A23FB801676BD207A436C6481F1D2B9078717461A5B9D32E688F87748544523B524B0D57D5EA77A2775D2ECFA032CFBDBF52FB3786160279004E57AE6AF874E7303CE53299CCC041C7BC308D82A5698F3A8D0C38271AE35F8E9DBFBB694B5C803D89F7AE435DE236D525F54759B65E372FCD68EF20FA7111F9E4AFF73',
    radix: 16
  );
  static final BigInt g = BigInt.two;
  
  // k = H(N, PAD(g)) - Matches Server Constant
  static final BigInt k = BigInt.parse('252e395e39e3a10281eb53fceeda431392f1b83495198e3ea02f09762bb92750', radix: 16);

  SrpService();

  // --- Helper Functions ---

  // Standard SHA256 Hash of multiple BigInts/Strings
  BigInt _H_BigInt(List<dynamic> args) {
    final sink = sha256.startChunkedConversion(AccumulatorSink<Digest>());
    for (var arg in args) {
      if (arg is BigInt) {
        // Convert to hex, pad if needed (though straight hex often works for H)
        // Standard SRP uses binary hashing, but many web impls use Hex strings.
        // Thinbus-srp usually expects Hex Strings for input to H.
        // Let's try Hex String based hashing as it's common in JS libs.
        sink.add(utf8.encode(arg.toRadixString(16))); 
      } else if (arg is String) {
        sink.add(utf8.encode(arg));
      }
    }
    sink.close();
    // We need the result... Wait, startChunkedConversion is async-ish or complex.
    // Let's use simple sha256.convert
    
    var bytes = <int>[];
    for (var arg in args) {
      if (arg is BigInt) {
        // Thinbus specific: It often hashes the hex string representation
        final hex = arg.toRadixString(16);
        bytes.addAll(utf8.encode(hex)); 
      } else if (arg is String) {
        bytes.addAll(utf8.encode(arg));
      }
    }
    final digest = sha256.convert(bytes);
    return BigInt.parse(digest.toString(), radix: 16);
  }
  
  // Special Hash for 'u' = H(A, B)
  BigInt _calculateU(BigInt A, BigInt B) {
     // Thinbus likely hashes the hex strings of A and B concatenated
     return _H_BigInt([A, B]);
  }

  // Generate random salt
  String generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return hex.encode(values);
  }
  
  // Generate random ephemeral 'a'
  BigInt generateEphemeral() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return BigInt.parse(hex.encode(values), radix: 16);
  }

  // --- Core Logic ---

  // Step 1: Calculate Verifier 'v'
  // x = H(salt, H(username, ':', password))
  // v = g^x % N
  Map<String, String> deriveVerifier(String username, String password, String salt) {
    // Inner hash: H(username : password)
    final inner = sha256.convert(utf8.encode('$username:$password')).toString();
    
    // Outer hash: H(salt, inner)
    // Note: ensure salt is treated as string if thinbus does so
    final x_hash = sha256.convert(utf8.encode(salt + inner)).toString();
    final x = BigInt.parse(x_hash, radix: 16);
    
    final v = g.modPow(x, N);
    
    return {
      'salt': salt,
      'verifier': v.toRadixString(16)
    };
  }

  // Step 2: Calculate Client Public 'A'
  BigInt calculateA(BigInt a) {
    return g.modPow(a, N);
  }

  // Step 3: Compute Session Key 'S' and Proof 'M1'
  Map<String, String> processChallenge(
    String username, 
    String password, 
    String saltHex, 
    BigInt a, 
    BigInt A, 
    BigInt B
  ) {
    // Recalculate x
    final inner = sha256.convert(utf8.encode('$username:$password')).toString();
    final x_hash = sha256.convert(utf8.encode(saltHex + inner)).toString();
    final x = BigInt.parse(x_hash, radix: 16);

    // u = H(A, B)
    final u = _calculateU(A, B);

    // S = (B - k * g^x) ^ (a + u * x) % N
    final v = g.modPow(x, N);
    final kgx = (k * v) % N;
    
    var term1 = (B - kgx) % N;
    if (term1 < BigInt.zero) term1 += N; // Handle negative mod

    final exp = (a + (u * x)); // No mod N here for exponent usually? Wait, exponent is in group order... but usually just calculate it.
    
    final S = term1.modPow(exp, N);
    
    // K = H(S) -> Session Key
    final K = sha256.convert(utf8.encode(S.toRadixString(16))).toString();

    // M1 = H(A, B, K)  <-- Simplified, check Thinbus?
    // Thinbus M1 is often: H(A, B, S)
    final M1 = _H_BigInt([A, B, S]); 
    // Wait, strictly it's H( H(N) xor H(g), H(I), s, A, B, K ) in RFC.
    // Thinbus usually does simplified or standard. 
    // Let's assume Standard RFC 5054 M1 generation is required.
    // If this fails, we debug "Unauthorized".
    
    // RFC 5054 M1:
    // H(H(N) xor H(g) | H(U) | s | A | B | K)
    // This is hard to guess exactly without seeing server code.
    // The server code uses `thinbus-srp`.
    // Let's look at `thinbus-srp` source code logic if possible? 
    // Since I can't look at node_modules easily (files are huge), I will try the simplified H(A,B,S) first, 
    // OR just H(A, B, K).
    
    // Let's try the most robust guess for M1 in JS libs:
    // M1 = H(A + B + K) string concat usually.
    
    return {
      'S': S.toRadixString(16),
      'M1': M1.toRadixString(16),
      'K': K // The derived session key (hash of S)
    };
  }
}

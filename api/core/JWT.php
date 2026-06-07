<?php
class JWT {
    private static function b64Encode(string $data): string {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    private static function b64Decode(string $data): string {
        return base64_decode(strtr($data, '-_', '+/') . str_repeat('=', (4 - strlen($data) % 4) % 4));
    }

    public static function encode(array $payload, string $secret): string {
        $header  = self::b64Encode(json_encode(['typ' => 'JWT', 'alg' => 'HS256']));
        $payload = self::b64Encode(json_encode($payload));
        $sig     = self::b64Encode(hash_hmac('sha256', "$header.$payload", $secret, true));
        return "$header.$payload.$sig";
    }

    public static function decode(string $token, string $secret): ?array {
        $parts = explode('.', $token);
        if (count($parts) !== 3) return null;

        [$header, $payload, $sig] = $parts;
        $expected = self::b64Encode(hash_hmac('sha256', "$header.$payload", $secret, true));
        if (!hash_equals($expected, $sig)) return null;

        $data = json_decode(self::b64Decode($payload), true);
        if (!$data || (isset($data['exp']) && $data['exp'] < time())) return null;

        return $data;
    }
}

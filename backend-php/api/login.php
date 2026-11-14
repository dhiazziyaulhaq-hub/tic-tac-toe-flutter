<?php

header('Content-Type: application/json; charset=utf-8');

require_once '/var/www/config/database.php';
require_once __DIR__ . '/cors.php';

// Hanya menerima POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Metode request harus POST'
    ]);
    exit;
}

// Membaca JSON
$data = json_decode(file_get_contents('php://input'), true);

if (!is_array($data)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Format JSON tidak valid'
    ]);
    exit;
}

$identifier = trim($data['identifier'] ?? '');
$password = $data['password'] ?? '';

if ($identifier === '' || $password === '') {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Username/email dan password wajib diisi'
    ]);
    exit;
}

try {
    // Mencari akun berdasarkan username atau email
    $stmt = $pdo->prepare(
        "SELECT id, username, email, password_hash, is_2fa_enabled
         FROM users
         WHERE username = :username OR email = :email
         LIMIT 1"
    );

    $stmt->execute([
        ':username' => $identifier,
        ':email' => $identifier
    ]);

    $user = $stmt->fetch();

    // Memeriksa akun dan password
    if (!$user || !password_verify($password, $user['password_hash'])) {
        http_response_code(401);

        echo json_encode([
            'success' => false,
            'message' => 'Username/email atau password salah'
        ]);
        exit;
    }

    // Jika 2FA aktif, arahkan ke verifikasi OTP
    if ((int) $user['is_2fa_enabled'] === 1) {
        echo json_encode([
            'success' => true,
            'message' => 'Password benar, silakan verifikasi OTP',
            'requires_2fa' => true,
            'user_id' => $user['id']
        ]);
        exit;
    }

    // Jika 2FA belum aktif
    echo json_encode([
        'success' => true,
        'message' => 'Login berhasil',
        'requires_2fa' => false,
        'user' => [
            'id' => $user['id'],
            'username' => $user['username'],
            'email' => $user['email']
        ]
    ]);

} catch (PDOException $e) {
    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Terjadi kesalahan pada server'
    ]);
}

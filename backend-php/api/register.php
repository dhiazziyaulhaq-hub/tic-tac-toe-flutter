<?php

header('Content-Type: application/json; charset=utf-8');

require_once '/var/www/config/database.php';
require_once __DIR__ . '/cors.php';

// Hanya menerima metode POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);

    echo json_encode([
        'success' => false,
        'message' => 'Metode request harus POST'
    ]);
    exit;
}

// Membaca data JSON
$data = json_decode(file_get_contents('php://input'), true);

if (!is_array($data)) {
    http_response_code(400);

    echo json_encode([
        'success' => false,
        'message' => 'Format JSON tidak valid'
    ]);
    exit;
}

// Mengambil input
$username = trim($data['username'] ?? '');
$email = trim($data['email'] ?? '');
$password = $data['password'] ?? '';

// Validasi input kosong
if ($username === '' || $email === '' || $password === '') {
    http_response_code(400);

    echo json_encode([
        'success' => false,
        'message' => 'Username, email, dan password wajib diisi'
    ]);
    exit;
}

// Validasi username
if (!preg_match('/^[a-zA-Z0-9_]{3,50}$/', $username)) {
    http_response_code(400);

    echo json_encode([
        'success' => false,
        'message' => 'Username harus 3-50 karakter dan hanya boleh berisi huruf, angka, atau underscore'
    ]);
    exit;
}

// Validasi email
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);

    echo json_encode([
        'success' => false,
        'message' => 'Format email tidak valid'
    ]);
    exit;
}

// Validasi password
if (strlen($password) < 8) {
    http_response_code(400);

    echo json_encode([
        'success' => false,
        'message' => 'Password minimal 8 karakter'
    ]);
    exit;
}

try {
    // Mengamankan password dengan hashing
    $passwordHash = password_hash($password, PASSWORD_DEFAULT);

    // Menyimpan akun ke database
    $stmt = $pdo->prepare(
        "INSERT INTO users (username, email, password_hash)
         VALUES (:username, :email, :password_hash)"
    );

    $stmt->execute([
        ':username' => $username,
        ':email' => $email,
        ':password_hash' => $passwordHash
    ]);

    http_response_code(201);

    echo json_encode([
        'success' => true,
        'message' => 'Registrasi berhasil',
        'user' => [
            'id' => $pdo->lastInsertId(),
            'username' => $username,
            'email' => $email
        ]
    ]);

} catch (PDOException $e) {
    // Username atau email sudah terdaftar
    if ($e->getCode() === '23000') {
        http_response_code(409);

        echo json_encode([
            'success' => false,
            'message' => 'Username atau email sudah digunakan'
        ]);
    } else {
        http_response_code(500);

        echo json_encode([
            'success' => false,
            'message' => 'Terjadi kesalahan pada server'
        ]);
    }
}

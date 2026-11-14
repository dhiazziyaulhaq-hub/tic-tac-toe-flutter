<?php
header('Content-Type: application/json; charset=utf-8');

require_once '/var/www/config/database.php';

try {
    $stmt = $pdo->query("SELECT DATABASE() AS database_name");
    $result = $stmt->fetch();

    echo json_encode([
        'success' => true,
        'message' => 'Koneksi PHP ke MySQL berhasil',
        'database' => $result['database_name']
    ]);

} catch (PDOException $e) {
    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'Query database gagal'
    ]);
}

<?php
/**
 * Exemple de configuration pour différents environnements
 * À adapter selon votre déploiement
 */

// Déterminer l'environnement
$environment = getenv('APP_ENV') ?: 'development';

// Configuration par environnement
$config = [
    'development' => [
        'db' => [
            'host' => 'localhost',
            'port' => 5432,
            'name' => 'unipay_db',
            'user' => 'unipay_admin',
            'password' => 'root1234',
            'charset' => 'utf8mb4',
        ],
        'cors' => [
            'allowed_origins' => [
                'http://localhost:3000',
                'http://localhost:8080',
                'http://localhost:5000',
                'http://127.0.0.1:3000',
                'http://127.0.0.1:8080',
                'http://127.0.0.1:5000',
                'file://',
            ],
        ],
        'log' => [
            'enabled' => true,
            'path' => __DIR__ . '/logs',
            'level' => 'DEBUG',
        ],
        'api' => [
            'timeout' => 30,
            'max_payload' => 1048576, // 1MB
        ],
    ],
    'staging' => [
        'db' => [
            'host' => getenv('DB_HOST') ?: 'db.staging.internal',
            'port' => 5432,
            'name' => 'unipay_db',
            'user' => getenv('DB_USER') ?: 'unipay_admin',
            'password' => getenv('DB_PASS'),
            'charset' => 'utf8mb4',
        ],
        'cors' => [
            'allowed_origins' => [
                'https://staging-app.unipay.example.com',
                'https://staging.unipay.example.com',
            ],
        ],
        'log' => [
            'enabled' => true,
            'path' => '/var/log/unipay',
            'level' => 'INFO',
        ],
        'api' => [
            'timeout' => 30,
            'max_payload' => 1048576,
        ],
    ],
    'production' => [
        'db' => [
            'host' => getenv('DB_HOST'),
            'port' => 5432,
            'name' => 'unipay_db',
            'user' => getenv('DB_USER'),
            'password' => getenv('DB_PASS'),
            'charset' => 'utf8mb4',
            'ssl' => true,
            'sslmode' => 'require',
        ],
        'cors' => [
            'allowed_origins' => [
                'https://unipay.example.com',
                'https://app.unipay.example.com',
            ],
        ],
        'log' => [
            'enabled' => true,
            'path' => '/var/log/unipay',
            'level' => 'WARNING',
        ],
        'api' => [
            'timeout' => 30,
            'max_payload' => 1048576,
        ],
    ],
];

// Retourner la configuration de l'environnement actuel
return $config[$environment] ?? $config['development'];

<?php
/**
 * Gestion des en-têtes CORS (Cross-Origin Resource Sharing)
 * Permet à l'application Flutter Web d'accéder à l'API depuis n'importe quel domaine
 */

function setupCORS() {
    // Récupérer l'origine demandée
    $origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : '*';

    // Liste des domaines autorisés
    $allowed_origins = [
        'http://localhost:3000',           // Flutter Web en développement
        'http://localhost:8080',           // Alternative Flutter Web
        'http://localhost:5000',           // Alternative
        'http://127.0.0.1:3000',
        'http://127.0.0.1:8080',
        'http://127.0.0.1:5000',
        'file://',                         // Pour les tests locaux
    ];

    // En production, à personnaliser selon votre domaine
    // 'https://unipay.example.com'
    // 'https://app.unipay.example.com'

    // Vérifier si l'origine est autorisée
    if (in_array($origin, $allowed_origins) || $origin === '*') {
        header('Access-Control-Allow-Origin: ' . $origin);
    } else {
        // Pour les origines non listées, rejeter avec le wildcard
        header('Access-Control-Allow-Origin: *');
    }

    // En-têtes CORS requis
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
    header('Access-Control-Allow-Credentials: true');
    header('Access-Control-Max-Age: 86400'); // 24 heures

    // Répondre aux requêtes preflight OPTIONS
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit;
    }
}

/**
 * Configurer les en-têtes JSON
 */
function setupJSON() {
    header('Content-Type: application/json; charset=utf-8');
}

/**
 * Fonction de validation des entrées
 */
function validateInput($data, $rules) {
    $errors = [];

    foreach ($rules as $field => $rule) {
        // Vérifier si le champ existe
        if ($rule['required'] && (empty($data[$field]) || $data[$field] === null)) {
            $errors[$field] = "Le champ {$field} est requis";
            continue;
        }

        // Vérifier le type si le champ n'est pas vide
        if (!empty($data[$field])) {
            if (isset($rule['type'])) {
                $value = $data[$field];
                switch ($rule['type']) {
                    case 'string':
                        if (!is_string($value)) {
                            $errors[$field] = "Le champ {$field} doit être une chaîne";
                        }
                        break;
                    case 'numeric':
                        if (!is_numeric($value)) {
                            $errors[$field] = "Le champ {$field} doit être un nombre";
                        }
                        break;
                    case 'email':
                        if (!filter_var($value, FILTER_VALIDATE_EMAIL)) {
                            $errors[$field] = "Le champ {$field} doit être un email valide";
                        }
                        break;
                    case 'integer':
                        if (!is_int($value) && !ctype_digit($value)) {
                            $errors[$field] = "Le champ {$field} doit être un entier";
                        }
                        break;
                }
            }

            // Vérifier la longueur min/max
            if (isset($rule['min']) && strlen($value) < $rule['min']) {
                $errors[$field] = "Le champ {$field} doit faire au moins {$rule['min']} caractères";
            }
            if (isset($rule['max']) && strlen($value) > $rule['max']) {
                $errors[$field] = "Le champ {$field} ne doit pas dépasser {$rule['max']} caractères";
            }
        }
    }

    return $errors;
}

/**
 * Sanitizer les entrées
 */
function sanitizeInput($input) {
    if (is_array($input)) {
        return array_map('sanitizeInput', $input);
    }
    return htmlspecialchars(trim($input), ENT_QUOTES, 'UTF-8');
}

/**
 * Logger les actions
 */
function logAction($action, $details = []) {
    $log_file = __DIR__ . '/logs/api.log';
    
    // Créer le dossier logs s'il n'existe pas
    if (!is_dir(dirname($log_file))) {
        mkdir(dirname($log_file), 0755, true);
    }

    $log_entry = [
        'timestamp' => date('Y-m-d H:i:s'),
        'action' => $action,
        'ip' => $_SERVER['REMOTE_ADDR'] ?? 'Unknown',
        'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown',
        'details' => $details
    ];

    $log_line = json_encode($log_entry) . PHP_EOL;
    error_log($log_line, 3, $log_file);
}

/**
 * Retourner une erreur au format JSON
 */
function jsonError($message, $code = 400, $details = []) {
    http_response_code($code);
    echo json_encode([
        'success' => false,
        'error' => $message,
        'details' => $details,
        'timestamp' => date('Y-m-d H:i:s')
    ]);
    exit;
}

/**
 * Retourner un succès au format JSON
 */
function jsonSuccess($data = null, $message = 'Succès') {
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => $message,
        'data' => $data,
        'timestamp' => date('Y-m-d H:i:s')
    ]);
    exit;
}

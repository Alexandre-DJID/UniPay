<?php
/**
 * Configuration et connexion à la base de données PostgreSQL
 * Utilise PDO pour une connexion sécurisée
 */

// Configuration de la base de données
define('DB_HOST', 'localhost');
define('DB_PORT', '5432');
define('DB_NAME', 'unipay_db');
define('DB_USER', 'unipay_admin');
define('DB_PASS', 'root1234');
define('DB_CHARSET', 'utf8mb4');

// Options PDO
$pdo_options = [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES => false,
];

try {
    // Créer la connexion DSN pour PostgreSQL
    $dsn = sprintf(
        'pgsql:host=%s;port=%d;dbname=%s;charset=%s',
        DB_HOST,
        DB_PORT,
        DB_NAME,
        DB_CHARSET
    );

    // Instantier la connexion PDO
    $pdo = new PDO($dsn, DB_USER, DB_PASS, $pdo_options);

    // Vérifier que la connexion est bien établie
    $pdo->exec("SET NAMES 'utf8'");

} catch (PDOException $e) {
    // Enregistrer l'erreur dans les logs (ne pas l'afficher en production)
    error_log('Erreur de connexion à la base de données: ' . $e->getMessage());
    
    // Retourner une erreur JSON générique (pas d'info sensible)
    http_response_code(500);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode([
        'success' => false,
        'error' => 'Erreur de connexion à la base de données',
        'code' => 'DB_CONNECTION_ERROR'
    ]);
    
    exit;
}

/**
 * Classe pour encapsuler les opérations de base de données
 */
class Database {
    private $pdo;

    public function __construct($pdo) {
        $this->pdo = $pdo;
    }

    /**
     * Exécuter une requête SELECT
     * @param string $query La requête SQL
     * @param array $params Les paramètres à binder
     * @return array Les résultats
     */
    public function query($query, $params = []) {
        try {
            $stmt = $this->pdo->prepare($query);
            $stmt->execute($params);
            return $stmt->fetchAll();
        } catch (PDOException $e) {
            error_log('Erreur SQL: ' . $e->getMessage());
            throw new Exception('Erreur lors de l\'exécution de la requête: ' . $e->getMessage());
        }
    }

    /**
     * Exécuter une requête qui retourne un seul résultat
     * @param string $query La requête SQL
     * @param array $params Les paramètres à binder
     * @return array|null Le résultat ou null
     */
    public function queryOne($query, $params = []) {
        $results = $this->query($query, $params);
        return !empty($results) ? $results[0] : null;
    }

    /**
     * Exécuter une requête INSERT, UPDATE ou DELETE
     * @param string $query La requête SQL
     * @param array $params Les paramètres à binder
     * @return int Le nombre de lignes affectées
     */
    public function execute($query, $params = []) {
        try {
            $stmt = $this->pdo->prepare($query);
            $stmt->execute($params);
            return $stmt->rowCount();
        } catch (PDOException $e) {
            error_log('Erreur SQL: ' . $e->getMessage());
            throw new Exception('Erreur lors de l\'exécution de la requête: ' . $e->getMessage());
        }
    }

    /**
     * Obtenir le dernier ID inséré
     * @return string|int L'ID inséré
     */
    public function lastInsertId() {
        return $this->pdo->lastInsertId();
    }

    /**
     * Commencer une transaction
     */
    public function beginTransaction() {
        $this->pdo->beginTransaction();
    }

    /**
     * Valider une transaction
     */
    public function commit() {
        $this->pdo->commit();
    }

    /**
     * Annuler une transaction
     */
    public function rollback() {
        $this->pdo->rollBack();
    }

    /**
     * Obtenir l'instance PDO
     * @return PDO
     */
    public function getPDO() {
        return $this->pdo;
    }
}

// Instancier la classe Database
$db = new Database($pdo);

// Fonction d'aide pour récupérer les erreurs
function getError($message) {
    return [
        'success' => false,
        'error' => $message,
        'timestamp' => date('Y-m-d H:i:s')
    ];
}

// Fonction d'aide pour retourner un succès
function getSuccess($data = null) {
    return [
        'success' => true,
        'data' => $data,
        'timestamp' => date('Y-m-d H:i:s')
    ];
}

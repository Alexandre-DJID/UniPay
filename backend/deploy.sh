#!/bin/bash

# ============================================================================
# Script de déploiement et d'installation de l'API UniPay
# ============================================================================

set -e

# Couleurs pour l'output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonctions de log
log() {
    echo -e "${GREEN}[✓]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Afficher le header
echo "========================================================================"
echo "  UniPay Backend API - Script de déploiement"
echo "========================================================================"
echo ""

# Déterminer le répertoire du script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# 1. Vérifier les prérequis
echo "Vérification des prérequis..."
echo ""

# Vérifier PHP
if ! command -v php &> /dev/null; then
    error "PHP n'est pas installé"
    exit 1
fi
PHP_VERSION=$(php -v | head -n 1)
log "PHP trouvé: $PHP_VERSION"

# Vérifier PostgreSQL
if ! command -v psql &> /dev/null; then
    warn "PostgreSQL client (psql) n'est pas installé - vous devrez charger le schéma manuellement"
else
    log "PostgreSQL client trouvé"
fi

echo ""

# 2. Créer la structure des dossiers
echo "Création de la structure des dossiers..."
mkdir -p logs
mkdir -p api
chmod 755 logs
log "Dossiers créés"
echo ""

# 3. Configurer les fichiers
echo "Configuration des fichiers..."

# Copier et adapter db.php si nécessaire
if [ ! -f "db.php" ]; then
    error "db.php n'existe pas"
    exit 1
fi
log "db.php trouvé"

# Copier et adapter cors.php si nécessaire
if [ ! -f "cors.php" ]; then
    error "cors.php n'existe pas"
    exit 1
fi
log "cors.php trouvé"

# Copier .env.example en .env s'il n'existe pas
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        log "Fichier .env créé à partir de .env.example"
        warn "Veuillez adapter les valeurs dans .env selon votre environnement"
    fi
else
    log "Fichier .env existe déjà"
fi

echo ""

# 4. Vérifier les permissions
echo "Vérification des permissions..."
if [ ! -w "logs" ]; then
    error "Le dossier logs n'est pas accessible en écriture"
    exit 1
fi
log "Dossier logs accessible en écriture"

if [ ! -r "db.php" ]; then
    error "Le fichier db.php n'est pas lisible"
    exit 1
fi
log "Fichiers de configuration lisibles"

echo ""

# 5. Tester la connexion à la base de données
echo "Test de connexion à la base de données..."
DB_TEST=$(php -r "
    require 'db.php';
    try {
        \$result = \$db->queryOne('SELECT 1 as connected');
        echo 'SUCCESS';
    } catch (Exception \$e) {
        echo 'FAILED: ' . \$e->getMessage();
    }
")

if [[ $DB_TEST == "SUCCESS" ]]; then
    log "Connexion à la base de données réussie"
else
    error "$DB_TEST"
    warn "Veuillez vérifier votre configuration de base de données"
    echo ""
    echo "Configuration actuelle attendue dans db.php:"
    echo "  DB_HOST: localhost"
    echo "  DB_PORT: 5432"
    echo "  DB_NAME: unipay_db"
    echo "  DB_USER: unipay_admin"
    echo "  DB_PASS: root1234"
    echo ""
fi

echo ""

# 6. Charger le schéma SQL
echo "Schéma de base de données..."
if [ -f "init_db.sql" ]; then
    read -p "Charger le schéma PostgreSQL maintenant? (o/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Oo]$ ]]; then
        # Récupérer les credentials depuis db.php
        DB_HOST=$(grep "define('DB_HOST'" db.php | cut -d"'" -f4)
        DB_PORT=$(grep "define('DB_PORT'" db.php | cut -d"'" -f4)
        DB_NAME=$(grep "define('DB_NAME'" db.php | cut -d"'" -f4)
        DB_USER=$(grep "define('DB_USER'" db.php | cut -d"'" -f4)
        
        read -sp "Mot de passe PostgreSQL: " DB_PASS
        echo ""
        
        if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f init_db.sql -q > /dev/null 2>&1; then
            log "Schéma de base de données chargé avec succès"
        else
            error "Impossible de charger le schéma"
            warn "Vous pouvez le charger manuellement avec:"
            echo "  psql -U $DB_USER -d $DB_NAME -f init_db.sql"
        fi
    else
        warn "Schéma non chargé - vous devrez le charger manuellement"
        echo "  psql -U unipay_admin -d unipay_db -f init_db.sql"
    fi
else
    warn "Fichier init_db.sql non trouvé"
fi

echo ""

# 7. Vérifier les endpoints
echo "Vérification des endpoints API..."
if [ -f "api/get_etudiant.php" ]; then
    log "Endpoint get_etudiant.php trouvé"
else
    error "Endpoint get_etudiant.php manquant"
fi

if [ -f "api/save_paiement.php" ]; then
    log "Endpoint save_paiement.php trouvé"
else
    error "Endpoint save_paiement.php manquant"
fi

echo ""

# 8. Afficher les instructions finales
echo "========================================================================"
echo "  Installation terminée!"
echo "========================================================================"
echo ""
echo "Prochaines étapes:"
echo "  1. Adapter la configuration .env selon votre environnement"
echo "  2. Vérifier les credentials PostgreSQL dans db.php"
echo "  3. Charger le schéma SQL si ce n'était pas fait:"
echo "     psql -U unipay_admin -d unipay_db -f init_db.sql"
echo ""
echo "Pour démarrer le serveur développement:"
echo "  php -S localhost:8000 -t ."
echo ""
echo "Pour tester les endpoints:"
echo "  curl 'http://localhost:8000/backend/api/get_etudiant.php?matricule=ETU-2025-001'"
echo ""
echo "Documentation complète dans:"
echo "  README.md"
echo ""

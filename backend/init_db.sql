-- ============================================================================
-- Schéma de base de données pour UniPay
-- PostgreSQL
-- ============================================================================

-- Désactiver les contraintes de clés étrangères temporairement
-- pour permettre les suppressions en cascade
SET session_replication_role = replica;

-- Supprimer les tables existantes (si elles existent)
DROP TABLE IF EXISTS reglement CASCADE;
DROP TABLE IF EXISTS tranche CASCADE;
DROP TABLE IF EXISTS fiche_engagement CASCADE;
DROP TABLE IF EXISTS etudiant CASCADE;

-- Réactiver les contraintes
SET session_replication_role = default;

-- ============================================================================
-- Table: etudiant
-- ============================================================================
CREATE TABLE etudiant (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    matricule VARCHAR(50) UNIQUE NOT NULL,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    telephone VARCHAR(20),
    niveau VARCHAR(20) NOT NULL, -- L1, L2, L3, M1, M2, Doctorat, etc.
    date_inscription TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actif BOOLEAN DEFAULT true,
    CONSTRAINT check_niveau CHECK (niveau IN ('L1', 'L2', 'L3', 'M1', 'M2', 'Doctorat', 'Cycle Ingénieur')),
    CONSTRAINT check_email CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$')
);

CREATE INDEX idx_etudiant_matricule ON etudiant(matricule);
CREATE INDEX idx_etudiant_email ON etudiant(email);

-- ============================================================================
-- Table: fiche_engagement
-- ============================================================================
CREATE TABLE fiche_engagement (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    etudiant_id UUID NOT NULL REFERENCES etudiant(id) ON DELETE CASCADE,
    annee_academique INTEGER NOT NULL,
    montant_total DECIMAL(12, 2) NOT NULL,
    montant_regle DECIMAL(12, 2) DEFAULT 0.00,
    statut VARCHAR(20) DEFAULT 'NON_PAYEE',
    notes TEXT,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_etudiant FOREIGN KEY (etudiant_id) REFERENCES etudiant(id) ON DELETE CASCADE,
    CONSTRAINT check_montant_total CHECK (montant_total > 0),
    CONSTRAINT check_montant_regle CHECK (montant_regle >= 0),
    CONSTRAINT check_statut CHECK (statut IN ('NON_PAYEE', 'PARTIELLEMENT_PAYEE', 'SOLDEE')),
    CONSTRAINT unique_fiche_etudiant_annee UNIQUE (etudiant_id, annee_academique)
);

CREATE INDEX idx_fiche_engagement_etudiant ON fiche_engagement(etudiant_id);
CREATE INDEX idx_fiche_engagement_annee ON fiche_engagement(annee_academique);
CREATE INDEX idx_fiche_engagement_statut ON fiche_engagement(statut);

-- ============================================================================
-- Table: tranche
-- ============================================================================
CREATE TABLE tranche (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fiche_id UUID NOT NULL REFERENCES fiche_engagement(id) ON DELETE CASCADE,
    numero INTEGER NOT NULL,
    montant_total DECIMAL(12, 2) NOT NULL,
    montant_regle DECIMAL(12, 2) DEFAULT 0.00,
    date_echeance DATE NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fiche FOREIGN KEY (fiche_id) REFERENCES fiche_engagement(id) ON DELETE CASCADE,
    CONSTRAINT check_montant_total CHECK (montant_total > 0),
    CONSTRAINT check_montant_regle CHECK (montant_regle >= 0),
    CONSTRAINT unique_tranche_numero UNIQUE (fiche_id, numero)
);

CREATE INDEX idx_tranche_fiche ON tranche(fiche_id);
CREATE INDEX idx_tranche_date_echeance ON tranche(date_echeance);

-- ============================================================================
-- Table: reglement
-- ============================================================================
CREATE TABLE reglement (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tranche_id UUID NOT NULL REFERENCES tranche(id) ON DELETE CASCADE,
    montant DECIMAL(12, 2) NOT NULL,
    type_reglement VARCHAR(20) NOT NULL,
    reference_transaction VARCHAR(100),
    notes TEXT,
    date_reglement TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    utilisateur VARCHAR(100),
    ip_adresse VARCHAR(45),
    CONSTRAINT fk_tranche FOREIGN KEY (tranche_id) REFERENCES tranche(id) ON DELETE CASCADE,
    CONSTRAINT check_montant_reglement CHECK (montant > 0),
    CONSTRAINT check_type_reglement CHECK (type_reglement IN ('ESPECES', 'MOBILE_MONEY', 'VIREMENT', 'CHEQUE'))
);

CREATE INDEX idx_reglement_tranche ON reglement(tranche_id);
CREATE INDEX idx_reglement_date ON reglement(date_reglement);
CREATE INDEX idx_reglement_type ON reglement(type_reglement);

-- ============================================================================
-- Données de test
-- ============================================================================

-- Insérer un étudiant de test
INSERT INTO etudiant (matricule, nom, prenom, email, telephone, niveau)
VALUES (
    'ETU-2025-001',
    'Kouassi',
    'Jean',
    'jean.kouassi@university.edu',
    '+225 07 12 34 56 78',
    'L2'
);

-- Récupérer l'ID de l'étudiant inséré
WITH student AS (
    SELECT id FROM etudiant WHERE matricule = 'ETU-2025-001'
)
-- Insérer la fiche d'engagement
INSERT INTO fiche_engagement (etudiant_id, annee_academique, montant_total, montant_regle, statut)
SELECT id, 2025, 450000.00, 250000.00, 'PARTIELLEMENT_PAYEE'
FROM student;

-- Insérer les tranches
WITH student AS (
    SELECT id FROM etudiant WHERE matricule = 'ETU-2025-001'
),
fiche AS (
    SELECT id FROM fiche_engagement WHERE etudiant_id = (SELECT id FROM student)
)
INSERT INTO tranche (fiche_id, numero, montant_total, montant_regle, date_echeance)
VALUES
    ((SELECT id FROM fiche), 1, 150000.00, 150000.00, '2025-09-30'),
    ((SELECT id FROM fiche), 2, 150000.00, 100000.00, '2025-12-31'),
    ((SELECT id FROM fiche), 3, 150000.00, 0.00, '2026-03-31');

-- Insérer des réglements de test
WITH student AS (
    SELECT id FROM etudiant WHERE matricule = 'ETU-2025-001'
),
fiche AS (
    SELECT id FROM fiche_engagement WHERE etudiant_id = (SELECT id FROM student)
),
tranches AS (
    SELECT id, numero FROM tranche WHERE fiche_id = (SELECT id FROM fiche)
)
INSERT INTO reglement (tranche_id, montant, type_reglement, reference_transaction, notes, utilisateur)
SELECT
    (SELECT id FROM tranches WHERE numero = 1),
    150000.00,
    'ESPECES',
    NULL,
    'Paiement 1ère tranche',
    'caissier_01'
UNION ALL
SELECT
    (SELECT id FROM tranches WHERE numero = 2),
    75000.00,
    'MOBILE_MONEY',
    'MTN-2025-001',
    'Paiement Mobile Money',
    'caissier_01'
UNION ALL
SELECT
    (SELECT id FROM tranches WHERE numero = 2),
    25000.00,
    'ESPECES',
    NULL,
    'Complément espèces',
    'caissier_01';

-- ============================================================================
-- Vues pour faciliter les requêtes
-- ============================================================================

-- Vue: Vue globale fiche avec calculs
CREATE OR REPLACE VIEW v_fiche_engagement_summary AS
SELECT
    f.id,
    f.etudiant_id,
    e.matricule,
    e.nom,
    e.prenom,
    e.email,
    e.telephone,
    e.niveau,
    f.annee_academique,
    f.montant_total,
    f.montant_regle,
    (f.montant_total - f.montant_regle) as reste_a_payer,
    ROUND((f.montant_regle::DECIMAL / f.montant_total * 100), 2) as pourcentage_paiement,
    f.statut,
    f.notes,
    f.date_creation,
    f.date_modification,
    COUNT(t.id) as nombre_tranches
FROM fiche_engagement f
LEFT JOIN etudiant e ON f.etudiant_id = e.id
LEFT JOIN tranche t ON f.id = t.fiche_id
GROUP BY f.id, e.id;

-- Vue: Résumé des tranches
CREATE OR REPLACE VIEW v_tranche_summary AS
SELECT
    t.id,
    t.fiche_id,
    t.numero,
    t.montant_total,
    t.montant_regle,
    (t.montant_total - t.montant_regle) as reste_a_payer,
    ROUND((t.montant_regle::DECIMAL / t.montant_total * 100), 2) as pourcentage_paiement,
    t.date_echeance,
    CASE
        WHEN t.montant_regle >= t.montant_total THEN 'PAYEE'
        WHEN CURRENT_DATE > t.date_echeance AND t.montant_regle < t.montant_total THEN 'ECHUE'
        ELSE 'EN_COURS'
    END as statut_tranche,
    COUNT(r.id) as nombre_reglements,
    SUM(r.montant) as montant_total_reglements
FROM tranche t
LEFT JOIN reglement r ON t.id = r.tranche_id
GROUP BY t.id;

-- ============================================================================
-- Triggers pour la mise à jour automatique
-- ============================================================================

-- Trigger: Mettre à jour montant_regle et statut dans fiche_engagement
CREATE OR REPLACE FUNCTION update_fiche_on_reglement()
RETURNS TRIGGER AS $$
DECLARE
    v_fiche_id UUID;
    v_montant_total DECIMAL;
    v_montant_regle DECIMAL;
    v_nouveau_statut VARCHAR;
BEGIN
    -- Récupérer l'ID de la fiche
    SELECT fiche_id INTO v_fiche_id FROM tranche WHERE id = NEW.tranche_id;

    -- Mettre à jour le montant reglé de la tranche
    UPDATE tranche
    SET montant_regle = montant_regle + NEW.montant,
        date_modification = CURRENT_TIMESTAMP
    WHERE id = NEW.tranche_id;

    -- Récupérer les montants de la fiche
    SELECT montant_total, SUM(montant_regle) INTO v_montant_total, v_montant_regle
    FROM tranche
    WHERE fiche_id = v_fiche_id
    GROUP BY montant_total;

    -- Déterminer le nouveau statut
    IF v_montant_regle >= v_montant_total THEN
        v_nouveau_statut := 'SOLDEE';
    ELSIF v_montant_regle > 0 THEN
        v_nouveau_statut := 'PARTIELLEMENT_PAYEE';
    ELSE
        v_nouveau_statut := 'NON_PAYEE';
    END IF;

    -- Mettre à jour la fiche d'engagement
    UPDATE fiche_engagement
    SET montant_regle = v_montant_regle,
        statut = v_nouveau_statut,
        date_modification = CURRENT_TIMESTAMP
    WHERE id = v_fiche_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Créer le trigger
DROP TRIGGER IF EXISTS trg_update_fiche_on_reglement ON reglement;
CREATE TRIGGER trg_update_fiche_on_reglement
AFTER INSERT ON reglement
FOR EACH ROW
EXECUTE FUNCTION update_fiche_on_reglement();

-- Trigger: Mettre à jour date_modification automatiquement
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.date_modification = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers de timestamp
DROP TRIGGER IF EXISTS trg_update_timestamp_etudiant ON etudiant;
CREATE TRIGGER trg_update_timestamp_etudiant
BEFORE UPDATE ON etudiant
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

DROP TRIGGER IF EXISTS trg_update_timestamp_fiche ON fiche_engagement;
CREATE TRIGGER trg_update_timestamp_fiche
BEFORE UPDATE ON fiche_engagement
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

DROP TRIGGER IF EXISTS trg_update_timestamp_tranche ON tranche;
CREATE TRIGGER trg_update_timestamp_tranche
BEFORE UPDATE ON tranche
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

-- ============================================================================
-- Droits et permissions
-- ============================================================================

-- Accorder les permissions à l'utilisateur unipay_admin (optionnel)
-- À exécuter en tant que superuser PostgreSQL
-- GRANT USAGE ON SCHEMA public TO unipay_admin;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO unipay_admin;
-- GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO unipay_admin;

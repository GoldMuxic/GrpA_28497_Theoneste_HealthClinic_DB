-- 1. Create Data Tablespace
CREATE TABLESPACE tbs_clinic_data 
    DATAFILE 'clinic_data_01.dbf' SIZE 100M AUTOEXTEND ON NEXT 50M;

-- 2. Create Index Tablespace
CREATE TABLESPACE tbs_clinic_idx 
    DATAFILE 'clinic_idx_01.dbf' SIZE 50M AUTOEXTEND ON NEXT 10M;

-- 3. Set Default Tablespace for your Admin User
ALTER USER admin_28497 DEFAULT TABLESPACE tbs_clinic_data;
ALTER USER admin_28497 QUOTA UNLIMITED ON tbs_clinic_data;
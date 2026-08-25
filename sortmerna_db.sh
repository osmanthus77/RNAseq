mkdir -p ~/database/sortmerna_db/rRNA_databases
cd ~/database/sortmerna_db/rRNA_databases
curl -LO https://github.com/sortmerna/sortmerna/releases/download/v7.0.0/smr_v4.3_default_db.fasta.gz
gzip -d smr_v4.3_default_db.fasta.gz
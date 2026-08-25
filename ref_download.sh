mkdir ref
#genome fasta
curl -L http://ftp.ebi.ac.uk/pub/ensembl/release-116/fasta/rattus_norvegicus/dna/Rattus_norvegicus.GRCr8.dna.toplevel.fa.gz -o ref/GRCr8.raw.fa.gz
gzip -d ref/GRCr8.raw.fa.gz
cat ref/GRCr8.raw.fa | perl -ne 'if (/^>(\S+)/) { print ">$1\n" }else { print }' > ref/GRCr8.fa
#index download
curl -L https://genome-idx.s3.amazonaws.com/hisat/rn6_genome.tar.gz -o ref/rn6.tar.gz
tar -xf ref/rn6.tar.gz -C ref/
# 8 ht2 file in ref/rn6
#hisat2 index build
#mkdir -p ref/index
#hisat2-build -p 6 ref/GRCr8.fa ref/index/GRCr8 > logs/ref_index.log
#gff
#curl -L http://ftp.ebi.ac.uk/pub/ensembl/release-116/gff3/rattus_norvegicus/Rattus_norvegicus.GRCr8.116.gff3.gz -o ref/GRCr8.gff3.gz
#gzip -d ref/GRCr8.gff3.gz
#gtf
curl -L http://ftp.ebi.ac.uk/pub/ensembl/release-116/gtf/rattus_norvegicus/Rattus_norvegicus.GRCr8.116.gtf.gz -o ref/GRCr8.gtf.gz
gzip -d ref/GRCr8.gtf.gz
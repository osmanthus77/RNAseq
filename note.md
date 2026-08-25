写snakemake测试时，单独运行某些步骤

```shell
snakemake --core 4 -j 1 --rerun-triggers mtime --forcerun HTseq --until HTseq
# HTseq是rule名
```

sortmerna、align在本机运行内存受限，所以设定`-j 1`

HTseq注释文件最好用`gtf`格式，默认输入bam是按name-sorted，输入bam/sam如果是position-sorted，加参数`--order pos`
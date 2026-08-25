import pandas as pd

# before 01_download
def load_group_info():
    """读取 group.tsv 的全部信息，返回以 Run 为索引的 DataFrame"""
    filepath = config["inputfile"]["groupfile"]
    df = pd.read_table(filepath, sep="\t", dtype=str)
    df.columns = df.columns.str.strip()      # 去掉列名两侧空格（如 "Sample Name"）
    df = df.dropna(how="all")                # 去掉全空行
    df = df.drop_duplicates(subset="Run")    # 按 Run 去重
    return df.set_index("Run")

GROUP = load_group_info()

SRR_IDS = GROUP.index.tolist()  # srr id list
SRR_type = GROUP["LibraryLayout"].to_dict()   # SRR -> type
SRR_treatment = GROUP["treatment"].to_dict()  # SRR -> treatment
SINGLE_SRRS = [srr for srr in SRR_IDS if SRR_type[srr] == "single"]
PAIRED_SRRS = [srr for srr in SRR_IDS if SRR_type[srr] == "paired"]
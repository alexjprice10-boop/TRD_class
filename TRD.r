library(readxl)
library(dplyr)
library(readr)
library(stringr)
library(ggplot2)


#Bring in the data
setwd("/Users/alexjprice10/Desktop/bioinfo/TRD")
bhutani.tbl <- read_csv("table_s9_human_genoinformativity.csv", skip = 1)
TRD.tbl <- read_delim("plink_poo_all_tests_gene_overlaps.txt", delim = "\t")

#Add a simple ensembl gene id that corresponds to bhutani.tbl in TRD
TRD.tbl <- TRD.tbl %>%
  mutate(Ensembl_gene_ID = as.factor(str_extract(GTF_attributes, "ENSG\\d+"))) %>%
  relocate(Ensembl_gene_ID, .before = 1)

#P-value adjust (should I adjust by the number of rows or number of different test (PAT, MAT, POO) times number of rows?)
  #so many ones its clear that my sample is too small for for the sake of this assignment we will use un adjusted
TRD.tbl <- TRD.tbl %>%
  mutate(P_PAT_ADJUST = p.adjust(P_PAT, method = "hochberg"),
         P_MAT_ADJUST = p.adjust(P_MAT, method = "hochberg"),
         P_POO_ADJUST = p.adjust(P_POO, method = "hochberg")
  )
  
#Significant or not (without p value adjustment)?
TRD.tbl <- TRD.tbl %>%
  mutate(P_PAT_SIG = ifelse(P_PAT < 0.05, "yes", "no"),
         P_MAT_SIG = ifelse(P_MAT < 0.05, "yes", "no"),
         P_POO_SIG = ifelse(P_POO_ADJUST < 0.05, "yes", "no"),
  )

#Summarize by genes (since there are multiple SNPs per gene) to have data on P/A of at least one SNP with significant TRD for every gene
TRD_genes.tbl <- TRD.tbl %>%
  group_by(Ensembl_gene_ID) %>%
  summarize(
    TRD_PAT = ifelse(any(P_PAT_SIG == "yes", na.rm = TRUE), "yes", "no"),
    TRD_MAT = ifelse(any(P_MAT_SIG == "yes", na.rm = TRUE), "yes", "no"),
    TRD_POO = ifelse(any(P_POO_SIG == "yes", na.rm = TRUE), "yes", "no")
  )

#Join TRD_genes.tbl to bhutani.tbl
TRD_genes.tbl <- TRD_genes.tbl %>%
  left_join(
    bhutani.tbl,
    by = c("Ensembl_gene_ID")
  ) %>%
  
  mutate(
    GIM = if_else(
      GIM_status_human_1 == "Confident GIM" | GIM_status_human_2 == "Confident GIM", "yes", "no", missing = "no"
    )
  )

#plot for paternal results
ggplot(data = TRD_genes.tbl, aes(x = GIM, fill = TRD_PAT)) +
  geom_bar(position = "fill") +
  geom_text(
    aes(label = scales::percent(after_stat(count / tapply(count, x, sum)[x]), accuracy = 0.1)),
    stat = "count",
    position = position_fill(vjust = 0.5),
    color = "black",
    fontface = "bold"
  ) +
  scale_x_discrete(labels = c("no" = "Non-GIM", "yes" = "GIM")) +
 
  scale_y_continuous(labels = scales::percent) +
  labs(
    x = NULL,
    y = NULL,
    fill = "Paternal TRD"
  ) +
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = "#222222", color = NA),
    panel.background = element_rect(fill = "#222222", color = NA),
    legend.background = element_rect(fill = "#222222", color = NA),
    legend.key = element_rect(fill = "#222222", color = NA),
    text = element_text(color = "white"),
    axis.text.x = element_text(size = 15, color = "white"),
    axis.text.y = element_text(size = 12, color = "white"),
    axis.title = element_text(color = "white"),
    axis.ticks = element_line(color = "white"),
    panel.grid.major = element_line(color = "#444444"),
    panel.grid.minor = element_blank(),
    legend.title = element_text(size = 15, color = "white"),
    legend.text = element_text(size = 13, color = "white")
  )

ggsave(
  "paternal_TRD.png",
  bg = "black",
  width = 6,
  height = 4.5,
  dpi = 600
)


#Plot for maternal results
ggplot(data = TRD_genes.tbl, aes(x = GIM, fill = TRD_MAT)) +
  geom_bar(position = "fill") +
  geom_text(
    aes(label = scales::percent(after_stat(count / tapply(count, x, sum)[x]), accuracy = 0.1)),
    stat = "count",
    position = position_fill(vjust = 0.5),
    color = "black",
    fontface = "bold"
  ) +
  scale_x_discrete(labels = c("no" = "Non-GIM", "yes" = "GIM")) +
  scale_fill_discrete(labels = c("no" = "Absent", "yes" = "Present")) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    x = NULL,
    y = NULL,
    fill = "Maternal TRD"
  ) +
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = "#222222", color = NA),
    panel.background = element_rect(fill = "#222222", color = NA),
    legend.background = element_rect(fill = "#222222", color = NA),
    legend.key = element_rect(fill = "#222222", color = NA),
    text = element_text(color = "white"),
    axis.text.x = element_text(size = 15, color = "white"),
    axis.text.y = element_text(size = 12, color = "white"),
    axis.title = element_text(color = "white"),
    axis.ticks = element_line(color = "white"),
    panel.grid.major = element_line(color = "#444444"),
    panel.grid.minor = element_blank(),
    legend.title = element_text(size = 15, color = "white"),
    legend.text = element_text(size = 13, color = "white")
  )


ggsave(
  "maternal_TRD.png",
  bg = "black",
  width = 6,
  height = 4.5,
  dpi = 600
)

#Do the fisher's exact test
fisher.test(TRD_genes.tbl$GIM, TRD_genes.tbl$TRD_PAT)
fisher.test(TRD_genes.tbl$GIM, TRD_genes.tbl$TRD_MAT)

#Comandos utilizados para os dados de abelha (Uruçu) 16s
#Utilizado no QIIME2

#Executando o QIIME2
    Abra o terminal na pasta do miniconda
    Utilize o "cd" para ir a pasta dos seus dados
    Ex : cd ../../../media/labbe-05/HD2/projetos/Metagenoma/dados/dados_labbe/
    Ativar o QIIME2
            <conda activate qiime2-2021.2>

#Importar dados demultiplexados
    Com todas as sequencias em uma pasta separadas o Forward do Reverse (Ex. .1 e .2)
    *Se os arqui
#Importar dados multiplexados
    Em uma pasta:
        Baixar o arquivo de metadados(Ex:sample-metadata.tsv)
        Criar outra pasta e colocar os arquivos (Forward e Reverse)
    
    *Se o dados que ta sendo utilizado ta zipado em outra extensão sem ser .gz, precisa baixar o arquivo, descompactar (gzip -d XXX) e depois compactar novamente (gzip XXX)

    Nosso caso são sequencias paired-end com barcode dentro do arquivo, então para importação fica:
        <qiime tools import   
        --type MultiplexedPairedEndBarcodeInSequence   
        --input-path muxed-pe-barcode-in-seq   
        --output-path multiplexed-seqs.qza>

#Desmultiplexar os dados (cutadapt demux-paired)
    Na nossa situação(paired-end com barcode no arquivo), o comando:
        <qiime cutadapt demux-paired                                   --i-seqs multiplexed-seqs.qza                           --m-forward-barcodes-file sample-metadata.tsv --m-forward-barcodes-column forwardprimer      --m-reverse-barcodes-file sample-metadata.tsv --m-reverse-barcodes-column reverseprimer              --o-per-sample-sequences demul.qza                --o-untrimmed-sequences demul-untrimmed.qza>

        *Nessa etapa pode usar o cutadapt ou demux, depende dos seus arquivos

    Após a demultiplexação, é útil gerar um resumo dos resultados da demultiplexação. Isso permite determinar quantas sequências foram obtidas por amostra e também obter um resumo da distribuição das qualidades da sequência em cada posição em seus dados de sequência.
        <qiime demux summarize \
        --i-data demul.qza \
        --o-visualization demul.qzv>
        <qiime tools view demul.qzv>

#Removendo sequências não biológicas (cutadapt)
    Se seus dados contiverem quaisquer sequências não biológicas (por exemplo, primers, adaptadores de sequenciamento, espaçadores de PCR, etc.), você deve removê-los.

#Mesclando leituras (vsearch join-pairs)
    Se você precisa ou não mesclar leituras depende de como você planeja agrupar ou diminuir o ruído de suas sequências em variantes de sequência de amplicon (ASVs) ou unidades taxonômicas operacionais (OTUs). Se você planeja usar deblur ou métodos de agrupamento OTU em seguida, junte suas sequências agora. Se você planeja usar o dada2 para remover ruído de suas sequências, não faça a fusão - o dada2 executa a fusão de leitura automaticamente após remover ruído de cada sequência.
        <qiime vsearch join-pairs                       --i-demultiplexed-seqs demul.qza                   --o-joined-sequences demul-join.qza>

    *NÃO PRECISA PRO NOSSO CASO

#Controle de qualidade de sequência (dada2)
    DADA2 é um pipeline para detectar e corrigir (quando possível) dados de sequência de amplicons da Illumina. Conforme implementado no q2-dada2plugin, este processo de controle de qualidade filtrará adicionalmente quaisquer leituras phiX (comumente presentes nos dados da sequência do gene marcador Illumina) que são identificadas nos dados de sequenciamento e filtrará as sequências quiméricas.

    O método requer dois parâmetros que são usados ​​na filtragem de qualidade:, que corta as primeiras bases de cada sequência e que trunca cada sequência na posição . Isso permite que o usuário remova regiões de baixa qualidade das sequências. Para determinar quais valores passar para esses dois parâmetros, você deve revisar a guia Gráfico de qualidade interativo no arquivo que foi gerado acima.dada2 denoise-single--p-trim-left mm--p-trunc-len nndemux.qzvqiime demux summarize
    
    No demux.qzv gráficos de qualidade, vemos que a qualidade das bases iniciais parece ser alta, portanto, não apararemos nenhuma base desde o início das sequências. A qualidade parece cair por volta da posição 150 no forward e 100 no reverse. O próximo comando pode levar até 10 minutos para ser executado e é a etapa mais lenta deste tutorial.  

        <qiime dada2 denoise-paired                  --i-demultiplexed-seqs demul.qza                    --p-trim-left-r 0                                       --p-trim-left-f 0                                    --p-trunc-len-f 150                                    --p-trunc-len-r 100                          --o-representative-sequences rep-seqs-dada.qza             --o-table table-dada.qza                                         --o-denoising-stats stats-dada.qza>

        <qiime metadata tabulate                                   --m-input-file stats-dada.qza                          --o-visualization stats-dada.qzv>

#Feature Table e Feature Data
    Após a conclusão da etapa de filtragem de qualidade, você desejará explorar os dados resultantes. Você pode fazer isso usando os dois comandos a seguir, que criarão resumos visuais dos dados. O comando fornecerá informações sobre quantas sequências estão associadas a cada amostra e a cada recurso, histogramas dessas distribuições e algumas estatísticas de resumo relacionadas. O comando fornecerá um mapeamento de IDs de recursos para sequências e fornecerá links para BLAST facilmente cada sequência contra o banco de dados NCBI nt. A última visualização será muito útil posteriormente no tutorial, quando você quiser aprender mais sobre recursos específicos que são importantes no conjunto de dados.feature-table summarizefeature-table tabulate-seqs

    <qiime feature-table summarize \
    --i-table table-dada.qza \
    --o-visualization table-dada.qzv \
    --m-sample-metadata-file sample-metadata.tsv>

    <qiime feature-table tabulate-seqs \
    --i-data rep-seqs-dada.qza \
    --o-visualization rep-seqs.qzv>

#Cluster de referencia fechado
    O agrupamento de referência fechado agrupa sequências que correspondem à mesma sequência de referência em um banco de dados com uma certa similaridade.

    O VSEARCH pode fazer clustering de referência fechada com o método cluster-features-closed-reference . Este método envolve a --usearch_globalfunção VSEARCH. Você pode decidir em qual banco de dados de referência será agrupado com o --i-reference-sequencessinalizador. O arquivo de entrada para este flag deve ser um .qza arquivo contendo um arquivo fasta com as sequências a serem utilizadas como referências, com tipo de dados QIIME 2 FeatureData[Sequence]. A maioria das pessoas usa GreenGenes ou SILVA para sequências do gene 16S rRNA, mas outros fazem a curadoria de seus próprios bancos de dados ou usam outras referências padrão (por exemplo, UNITE para dados ITS). Você pode baixar as referências dos links na página de recursos de dados QIIME 2 . Você precisará descompactar / descompactar e importá-los como FeatureData[Sequence]artefatos, já que eles são fornecidos como arquivos de dados brutos.
    Baixei o arquivo pronto do QIIME2, contendo a sequencia completa do SILVA
    <qiime vsearch cluster-features-closed-reference \
    --i-sequences rep-seqs-dada.qza \
    --i-table table-dada.qza \
    --i-reference-sequences silva-seqs.qza \
    --o-clustered-table table-cluster.qza \
    --o-clustered-sequences seqs-cluster.qza \
    --o-unmatched-sequences seqs-unmatched.qza \
    --p-perc-identity 0.97>

#Atribuir taxonomia (feature-classifier)
    A atribuição de taxonomia a sequências representativas de ASV ou OTU é abordada no tutorial de classificação de taxonomia . Todos os métodos de atribuição de taxonomia estão no plug-in classificador de recursos .

    Existem duas abordagens principais para atribuir taxonomia, cada uma com vários métodos disponíveis.

    O primeiro envolve o alinhamento de leituras para referenciar bancos de dados diretamente:

    classify-consensus-blast : BLAST + alinhamento local

    classify-consensus-vsearch : alinhamento global VSEARCH

    Ambos utilizam o consenso abordagem de atribuição taxonomia, que você pode aprender mais sobre na visão geral e ajustar com as maxaccepts, perc-identitye min-consensusparâmetros.

    A segunda abordagem usa um classificador de aprendizado de máquina para atribuir taxonomias prováveis ​​às leituras e pode ser usada por meio do método classify-sklearn .

    Este método precisa de um modelo pré-treinado para classificar as sequências: você pode baixar um dos classificadores de taxonomia pré-treinados da página de recursos de dados ou treinar um você mesmo (seguindo as etapas descritas no tutorial do classificador de recursos ). (Você também pode aprender muito mais sobre os modelos específicos implementados no documento associado ao plug-in .)

    '<qiime feature-classifier classify-sklearn \
    --i-reads seqs-cluster.qza \
    --i-classifier silva-tax.qza \
    --o-classification seqs-cluster-taxa.qza>'
    #NÃO DEU CERTO AINDA

    <qiime feature-classifier classify-consensus-vsearch \
    --i-query seqs-cluster.qza \
    --i-reference-reads silva-seqs.qza \
    --i-reference-taxonomy silva-tax.qza \
    --o-classification seqs-cluster-tax.qza>

    <qiime metadata tabulate \
    --m-input-file taxonomy.qza \
    --o-visualization taxonomy.qzv>

#Gerar árvore para ánalise de diversidade filogenética
    QIIME suporta várias métricas de diversidade filogenética, incluindo Faiths Phylogenetic Diversity e UniFrac ponderada e não ponderada. Além das contagens de características por amostra (ou seja, os dados no FeatureTable[Frequency]artefato QIIME 2), essas métricas requerem uma árvore filogenética enraizada relacionando as características entre si. Essas informações serão armazenadas em um Phylogeny[Rooted]artefato QIIME 2. Para gerar uma árvore filogenética, usaremos o align-to-tree-mafft-fasttreepipeline do q2-phylogenyplugin.

    Primeiro, o pipeline usa o mafftprograma para realizar um alinhamento de sequência múltipla das sequências em nosso FeatureData[Sequence]para criar um FeatureData[AlignedSequence]artefato QIIME 2. Em seguida, o pipeline mascara (ou filtra) o alinhamento para remover posições que são altamente variáveis. Essas posições são geralmente consideradas para adicionar ruído a uma árvore filogenética resultante. Em seguida, o pipeline aplica FastTree para gerar uma árvore filogenética a partir do alinhamento mascarado. O programa FastTree cria uma árvore sem raiz, portanto, na etapa final desta seção, o enraizamento do ponto médio é aplicado para colocar a raiz da árvore no ponto médio da maior distância ponta a ponta na árvore sem raiz.

    <qiime phylogeny align-to-tree-mafft-fasttree --i-sequences rep-seqs-dada.qza --o-alignment aligned-rep-seqs.qza --o-masked-alignment masked-aligned-rep-seqs.qza --o-tree unrooted-tree.qza --o-rooted-tree rooted-tree.qza>

#FIM :) 
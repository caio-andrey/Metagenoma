#Comandos para teste de 16s
#Qualquer bug olhar o fórum:
    https://forum.qiime2.org/

#Dicas
    01: Se a qualquer momento você quiser ver quais arquivos reais estão no .qzaartefato, você pode usar o qiime tools export para extrair o arquivo de dados diretamente (que é basicamente apenas um invólucro para unzip). Como alternativa, você também pode descompactar seu artefato diretamente ( ) e examinar os arquivos na pasta.unzip 
    <-k file.qzadata/>

    02: As ferramentas de interface de linha de comando QIIME 2 são lentas porque precisam descompactar e compactar novamente os dados contidos nos artefatos cada vez que você os chama.

#Etapas de processamento de dados
    01: Importando dados de sequência bruta (FASTQ) para o qiime2
    02: Dados de demultiplexação (ou seja, mapeando cada sequência para a amostra de onde veio)
    03: Removendo partes não biológicas das sequências (ou seja, primers)
    04: Realizando controle de qualidade e:
        Sequências de remoção de ruído com DADA2 ou deblur, e / ou
        Filtragem de qualidade, corte de comprimento e agrupamento com VSEARCH ou dbOTU
    05: Atribuição taxonomica
    06: Analise dos dados e com visão

#Importando Dados
    Se um colaborador fornece a você uma tabela de características em .biomformato, você pode importá-la para um artefato QIIME 2 para realizar análises estatísticas “downstream” que operam em uma tabela de características.
    
    Para ver uma lista completa de tipos de importação / formato disponíveis, use: 
    <e qiime tools import --show-importable-formats>
    <qiime tools import --show-importable-types>

    #Importação de FASTQC
        Tipos de dados FASTQ:
        Dados FASTQ com o formato do protocolo EMP
        Dados FASTQ multiplexados com barcode em sequências
        Dados FASTQ no formato demultiplexado Casava 1.8
        Quaisquer dados FASTQ não representados nos itens da lista acima

    #FASTQ
    Se você estiver importando dados FASTQ que gerou, provavelmente precisará gerar um arquivo de manifesto , que é apenas um arquivo de texto que mapeia cada arquivo FASTQ para sua ID de amostra e direção (se aplicável).
    Arquivo manifesto
        https://owko75lmoyh5bzxgwbxdeonqvm--docs-qiime2-org.translate.goog/2021.2/tutorials/importing/#manifest-file

    #FASTQ multiplexado paired-end com barcode na sequência
        Precisa ter três coisas para poder rodar:
        01: O forward.fastq.gz artefato, contendo leituras de encaminhamento de várias amostras
        02: O reverse.fastq.gz artefato, contendo leituras reversas das mesmas amostras.
        03: Um arquivo de metadados com uma coluna de códigos de barras por amostra para uso em demultiplexação FASTQ (ou duas colunas de códigos de barras de índice duplo)

    *Como você está importando um diretório de vários arquivos, os nomes de arquivo forward.fastq.gz e reverse.fastq.gz são necessários.

    #Testa arquivos FASTQ multiplexado
        Criar pasta para o teste
            <mkdir muxed-pe-barcode-in-seq>
        
        Baixar o forward
            <wget \ -O "muxed-pe-barcode-in-seq/forward.fastq.gz" \ "https://data.qiime2.org/2021.2/tutorials/importing muxed-pe-barcode-in-seq/forward.fastq.gz">
        
        Baixar a reverse
            <wget \ -O "muxed-pe-barcode-in-seq/reverse.fastq.gz" \ "https://data.qiime2.org/2021.2/tutorials/importing/muxed-pe-barcode-in-seq/reverse.fastq.gz">

        Importando dados
            <qiime tools import \ 
            --type MultiplexedPairedEndBarcodeInSequence \
            --input-path muxed-pe-barcode-in-seq \
            --output-path multiplexed-seqs.qza>

    #Ver outros tipos de dados para importação
        https://owko75lmoyh5bzxgwbxdeonqvm--docs-qiime2-org.translate.goog/2021.2/tutorials/importing/

        
    #Testar arquivos de metados
        <mkdir qiime2-metadata-tutorial
        <cd qiime2-metadata-tutorial
        <wget \ -O "sample-metadata.tsv" \ "https://data.qiime2.org/2021 2/tutorials/moving-pictures/sample_metadata.tsv">

        <qiime metadata tabulate \
        --m-input-file sample-metadata.tsv \
        --o-visualization tabulated-sample-metadata.qzv>

    



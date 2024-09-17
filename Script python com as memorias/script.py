def process_files():
    # Lê o conteúdo de binario.txt
    with open('binario.txt', 'r') as binario:
        linhas = binario.readlines()

    # Verifica quantas linhas tem o arquivo binario.txt
    total_linhas = len(linhas)

    # Se houver menos de 2047 linhas, preenche com "00000000"
    if total_linhas < 2047:
        for _ in range(2047 - total_linhas):
            linhas.append("00000000\n")

    # Escreve o conteúdo no arquivo arquivo.txt
    with open('arquivo.txt', 'w') as arquivo:
        arquivo.writelines(linhas)

    print("A primeira parte do arquivo.txt foi criada com 2047 linhas.")

    # Lê o conteúdo de data.txt
    with open('data.txt', 'r') as data:
        linhas_data = data.readlines()

    # Adiciona o conteúdo de data.txt ao final de arquivo.txt
    with open('arquivo.txt', 'a') as arquivo:
        arquivo.writelines(linhas_data)

    print("Processo concluído. O conteúdo de data.txt foi adicionado a arquivo.txt.")

# Executa o processo
process_files()

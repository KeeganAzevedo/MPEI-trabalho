% Carregar os dados JSON
nomeArquivo = 'livros_dados.json';
jsonData = jsondecode(fileread(nomeArquivo));
numLivros = length(jsonData);

% Inicializar vetores para os dados principais
ID = zeros(numLivros, 1);
Titulos = strings(numLivros, 1);
Autores = strings(numLivros, 1);
Generos = strings(numLivros, 1);
AnoPublicacao = zeros(numLivros, 1);
Editoras = strings(numLivros, 1);
Resumos = strings(numLivros, 1);
Historicos = strings(numLivros, 1);

% Processamento dos dados JSON
for i = 1:numLivros
    ID(i) = jsonData(i).id;
    Titulos(i) = jsonData(i).titulo;
    Autores(i) = jsonData(i).autor;
    Generos(i) = jsonData(i).genero;
    AnoPublicacao(i) = jsonData(i).ano_publicacao;
    Editoras(i) = jsonData(i).editora;
    Resumos(i) = jsonData(i).resumo;

    % Processar histórico de empréstimos
    historico = "";
    for j = 1:length(jsonData(i).historico_emprestimo)
        entry = jsonData(i).historico_emprestimo(j);
        historico = historico + sprintf("ID Usuário: %s, Empréstimo: %s, Devolução: %s; ", ...
            entry.id_usuario, entry.data_emprestimo, entry.data_devolucao);
    end
    Historicos(i) = historico;
end

% Criar tabela com os dados
livros = table(ID, Titulos, Autores, Generos, AnoPublicacao, Editoras, Resumos, Historicos);

% Exibir uma mensagem inicial
fprintf('Bem-vindo ao Sistema de Gestão de Livros!\n');

% Loop do Menu
opcao = 0;
while opcao ~= 4
    fprintf('\nEscolha uma opção:\n');
    fprintf('1. Classificar Gênero de Livros (Naive Bayes)\n');
    fprintf('2. Buscar Livro (ID e Título - Bloom Filter)\n');
    fprintf('3. Recomendar Livros (MinHash)\n');
    fprintf('4. Sair\n');
    
    opcao = input('Digite o número da opção desejada: ');
    
    switch opcao
        case 1
            % Classificador Bayes
            fprintf('\n--- Classificação de Livros ---\n');
            TitulosTest = input('Digite os títulos dos livros (como array ["titulo1", "titulo2"]): ');
            ResumosTest = input('Digite os resumos dos livros (como array ["resumo1", "resumo2"]): ');
            fprintf('\n-----------------------\n')
            
            generosPrevistos = classificarLivrosNaiveBayes(Titulos, Resumos, Generos, TitulosTest, ResumosTest);
            fprintf('Gêneros previstos para os livros testados:\n');
            disp(generosPrevistos);
            
        case 2
            % Busca usando Bloom Filter
            fprintf('\n--- Busca de Livro ---\n');
            livroBuscaID = input('Digite o ID do livro: ', 's');
            livroBuscaTitulo = input('Digite o título do livro: ', 's');
            usuarioBusca = input('Digite o ID do usuário: ', 's');
            fprintf('\n-----------------------\n')
            
            Bloomfilter(livroBuscaID, livroBuscaTitulo, usuarioBusca,nomeArquivo);
            
        case 3
            % Recomendações com MinHash
            fprintf('\n--- Recomendações de Livros ---\n');
            idUsuario = input('Digite o ID do usuário: ', 's');
            nTop = input('Digite o número de recomendações desejadas: ');
            fprintf('\n-----------------------\n')
            
            minash_usuario(idUsuario, nTop, nomeArquivo);
            
        case 4
            fprintf('Saindo do sistema. Até mais!\n');
        otherwise
            fprintf('Opção inválida. Tente novamente.\n');
    end
end

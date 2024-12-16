jsonData = jsondecode(fileread('livros_dados.json'));

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

% Criar uma tabela com os dados
livros = table(ID, Titulos, Autores, Generos, AnoPublicacao, Editoras, Resumos, Historicos);
disp(livros);


%%
%Classificador Bayes
% exemplo de dois Livros para procurar Genero
TitulosTest = ["A Brief History of Time", "Advanced Machine Learning"];
ResumosTest = ["A book about the history of cosmology and black holes.", ...
               "An in-depth study on algorithms and data structures for AI."];
% Utiliza as variaveis de treino obtidas anteriormente para definir o
% genero de uma nova variavel de teste e retorna o genero previsto
generosPrevistos = classificarLivrosNaiveBayes(Titulos, Resumos, Generos, TitulosTest, ResumosTest);
disp(generosPrevistos);


%%
%BF


%%
%MINHASH


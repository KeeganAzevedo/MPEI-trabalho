function minash_usuario(idUsuario,nTop,arquivoJSON)
    function sistemaRecomendacoesUsuario()
        % Configuração inicial
        ks = 3;  % Tamanho dos shingles (substrings consecutivas)
        k = 100; % Número de funções hash
        p = 123456789; % Número primo usado no hashing
        while ~isprime(p)
            p = p + 2; % Incrementar até encontrar um número primo
        end
        R = randi(p, k, ks); % Gerar matriz de coeficientes aleatórios para hash
    
        % Ler dados do arquivo JSON
        dados = lerArquivoJSON(arquivoJSON);
    
        % Processar dados dos livros (resumos, gêneros, avaliações)
        [resumosSet, generosSet, ~, titulos, ~] = processarLivrosUsuarios(dados, ks);
    
        % Calcular assinaturas MinHash 
        MA_generos = calcularAssinaturasMinHash(generosSet, length(dados), k, R, p);
   
    
        % Buscar os livros alugados pelo usuário
        livrosAlugados = encontrarLivrosPorUsuario(idUsuario, dados);
    
        if isempty(livrosAlugados)
            disp(['Nenhum livro alugado foi encontrado para o usuário com ID: ', idUsuario]);
            return;
        end
    
        % Exibir livros alugados
        disp(['Livros alugados pelo usuário com ID: ', idUsuario]);
        for i = 1:length(livrosAlugados)
            disp(['- ', titulos{livrosAlugados(i)}]);
        end
        % Recomendações baseadas em similaridade Jaccard (resumos)
        disp('Recomendações baseadas na similaridade dos resumos:');
        recomendarBaseadoEmJaccard(dados, resumosSet, titulos, livrosAlugados, nTop);
    
        % Recomendações baseadas nos gêneros
        disp('Recomendações baseadas nos gêneros:');
        recomendarBaseadoEmLivros(MA_generos, titulos, livrosAlugados, nTop);
    end
    
    % Função para ler o arquivo JSON
    function dados = lerArquivoJSON(nomeArquivo)
        if ~isfile(nomeArquivo)
            error('O arquivo JSON "%s" não foi encontrado.', nomeArquivo);
        end
        fid = fopen(nomeArquivo, 'r');
        raw = fread(fid, inf); % Ler o conteúdo completo do arquivo
        str = char(raw'); % Converter para string
        fclose(fid);
        dados = jsondecode(str); % Decodificar JSON
    end
    
    % Função para processar os dados dos livros
    function [resumosSet, generosSet, avaliacoesSet, titulos, idsUsuarios] = processarLivrosUsuarios(dados, ks)
        Nt = length(dados); % Número total de livros
        resumosSet = cell(Nt, 1); % Conjuntos de shingles dos resumos
        generosSet = cell(Nt, 1); % Conjuntos de shingles dos gêneros
        avaliacoesSet = cell(Nt, 1); % Avaliações por usuários
        titulos = cell(Nt, 1); % Títulos dos livros
        idsUsuarios = cell(Nt, 1); % IDs dos usuários que alugaram os livros
    
        for i = 1:Nt
            resumosSet{i} = criarShingles(dados(i).resumo, ks); % Criar shingles do resumo
            generosSet{i} = criarShingles(dados(i).genero, ks); % Criar shingles do gênero
    
            if isfield(dados(i), 'historico_emprestimo')
                usuarios = {dados(i).historico_emprestimo.id_usuario}; % IDs dos usuários que alugaram o livro
                avaliacoesSet{i} = usuarios;
                idsUsuarios{i} = usuarios;
            else
                avaliacoesSet{i} = {};
                idsUsuarios{i} = {};
            end
    
            titulos{i} = dados(i).titulo; % Guardar o título do livro
        end
    end
    
    % Função para criar shingles a partir de um texto
    function shingles = criarShingles(texto, ks)
        texto = lower(regexprep(texto, '[^a-zA-Z0-9\s]', '')); % Limpar e converter para minúsculas
        numShingles = length(texto) - ks + 1;
        shingles = cell(1, numShingles);
    
        for i = 1:numShingles
            shingles{i} = texto(i:i + ks - 1); % Criar shingles consecutivos
        end
    end
    
    % Função para encontrar livros alugados por um usuário
    function livrosAlugados = encontrarLivrosPorUsuario(idUsuario, dados)
        livrosAlugados = [];
        for i = 1:length(dados)
            if isfield(dados(i), 'historico_emprestimo')
                usuarios = {dados(i).historico_emprestimo.id_usuario};
                if any(strcmp(usuarios, idUsuario))
                    livrosAlugados = [livrosAlugados, i]; % Adicionar o índice do livro alugado
                end
            end
        end
    end
    
    % Função para calcular assinaturas MinHash
    function assinaturas = calcularAssinaturasMinHash(Set, Nt, k, R, p)
        assinaturas = zeros(k, Nt); % Inicializar a matriz de assinaturas
    
        for hf = 1:k
            for c = 1:Nt
                conjunto = Set{c};
                hc = zeros(1, length(conjunto));
    
                for nelem = 1:length(conjunto)
                    elemento = conjunto{nelem};
                    hc(nelem) = hashFunctionShingles(elemento, hf, R, p); % Aplicar função hash
                end
                assinaturas(hf, c) = min(hc); % Guardar o menor hash (MinHash)
            end
        end
    end
    
    % Função hash para shingles
    function hc = hashFunctionShingles(shingle, hf, R, p)
        r = R(hf, :); % Obter linha da matriz de coeficientes
        ascii = double(shingle); % Converter o shingle para valores ASCII
        hc = mod(ascii * r', p); % Calcular o hash
    end
    % Função para recomendar livros baseados em similaridade
    function recomendarBaseadoEmLivros(MA, titulos, livrosBase, nTop)
        similaridades = zeros(size(MA, 2), 1);
    
        for i = 1:length(livrosBase)
            livroID = livrosBase(i);
            assinaturaTeste = MA(:, livroID);
            similaridades = similaridades + calcularSimilaridade(MA, assinaturaTeste)'; % Somar similaridades
        end
    
        similaridades = similaridades / length(livrosBase); % Calcular média de similaridades
    
        % Exibir recomendações
        mostrarTopRecomendacoes(similaridades, titulos, livrosBase, nTop);
    end
    
    % Função para exibir recomendações ordenadas
    function mostrarTopRecomendacoes(similaridades, titulos, livrosExcluidos, nTop)
        [~, idx] = maxk(similaridades, nTop + length(livrosExcluidos)); % Obter índices das maiores similaridades
        idx = setdiff(idx, livrosExcluidos); % Excluir livros já alugados
        idx = idx(1:min(nTop, length(idx))); % Limitar às recomendações solicitadas
    
        for i = 1:length(idx)
            disp(['- ', titulos{idx(i)}, ' (Similaridade: ', num2str(similaridades(idx(i))), ')']);
        end
    end
    
    % Função para calcular similaridades de assinaturas
    function similaridades = calcularSimilaridade(assinaturas, assinaturaTeste)
        similaridades = mean(assinaturas == assinaturaTeste, 1); % Comparar assinaturas
    end
    
    % Atualização da função para recomendar livros usando similaridade Jaccard
    function recomendarBaseadoEmJaccard(datos, resumenesSet, titulos, librosAlquilados, nTop)
        % Calcular similaridade Jaccard com os livros base
        Nt = length(datos);
        similaridades = zeros(1, Nt);
    
        for i = 1:Nt
            if ~ismember(i, librosAlquilados)
                similitudes = zeros(1, length(librosAlquilados));
                for j = 1:length(librosAlquilados)
                    similitudes(j) =calcularJaccard(resumenesSet{i}, resumenesSet{librosAlquilados(j)});
                end
                similaridades(i) = mean(similitudes);
            end
        end
    
        % Mostrar recomendações
        mostrarTopRecomendacoes(similaridades, titulos, librosAlquilados, nTop);
    end
    
    % Função para calcular similaridade Jaccard entre dois conjuntos
    function J = calcularJaccard(setA, setB)
        interseccion = length(intersect(setA, setB));
        unionSet = length(union(setA, setB));
        if unionSet == 0
            J = 0; % Evitar divisão por zero
        else
            J = interseccion / unionSet;
        end
    end
sistemaRecomendacoesUsuario()
end

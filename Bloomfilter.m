% Sistema de Bloom Filter para Livros e Usuários com Arquivo JSON

% Inicializar Bloom Filter
function BF = inicializarBloomFilter(tamanho)
    BF = zeros(1, tamanho);
end

% Função hash genérica
function hash = string2hash(str, tipo)
    str = double(str); % Converter string para matriz de caracteres
    if nargin < 2, tipo = 'djb2'; end
    switch tipo
        case 'djb2'
            hash = 5381 * ones(size(str, 1), 1);
            for i = 1:size(str, 2)
                hash = mod(hash * 33 + str(:, i), 2^32 - 1);
            end
        case 'sdbm'
            hash = zeros(size(str, 1), 1);
            for i = 1:size(str, 2)
                hash = mod(hash * 65599 + str(:, i), 2^32 - 1);
            end
        otherwise
            error('string2hash:input', 'Tipo desconhecido');
    end
end

% Adicionar ao Bloom Filter
function BF = adicionarAoBloom(dado, BF, k)
    n = length(BF);
    for i = 1:k
        chaveModificada = [dado num2str(i)];
        hash_code = string2hash(chaveModificada, 'djb2');
        indice = mod(hash_code, n) + 1;
        BF(indice) = 1;
    end
end

% Verificar no Bloom Filter
function existe = verificarNoBloom(dado, BF, k)
    n = length(BF);
    bits = zeros(1, k);
    for i = 1:k
        chaveModificada = [dado num2str(i)];
        hash_code = string2hash(chaveModificada, 'djb2');
        indice = mod(hash_code, n) + 1;
        bits(i) = BF(indice);
    end
    existe = all(bits);
end

% Ler arquivo JSON e processar dados
function dados = lerArquivoJSON(nomeArquivo)
    if ~isfile(nomeArquivo)
        error('Arquivo JSON "%s" não encontrado.', nomeArquivo);
    end
    fid = fopen(nomeArquivo, 'r');
    raw = fread(fid, inf); % Ler todo o conteúdo do arquivo
    str = char(raw'); % Converter para string
    fclose(fid);
    dados = jsondecode(str); % Decodificar JSON
end

% Gerenciar livros e usuários com arquivo JSON
function gerenciarSistema()
    % Inicialização dos filtros
    tamanhoBloom = 1000; % Tamanho do Bloom Filter
    numHashes = 3; % Número de funções hash
    BF_livros = inicializarBloomFilter(tamanhoBloom);
    BF_usuarios = inicializarBloomFilter(tamanhoBloom);

    % Ler dados do arquivo JSON
    nomeArquivo = 'livros_dados.json';
    dados = lerArquivoJSON(nomeArquivo);

    % Processar cada livro do JSON
    for i = 1:length(dados)
        livro = dados(i);

        % Adicionar livro ao Bloom Filter
        BF_livros = adicionarAoBloom(num2str(livro.id), BF_livros, numHashes);
        BF_livros = adicionarAoBloom(livro.titulo, BF_livros, numHashes);

        % Adicionar histórico de empréstimos ao Bloom Filter
        for j = 1:length(livro.historico_emprestimo)
            id_usuario = livro.historico_emprestimo(j).id_usuario;
            BF_usuarios = adicionarAoBloom(id_usuario, BF_usuarios, numHashes);
        end
    end

    % Exemplo de verificações
    livroBuscaID = '3';
    livroBuscaTitulo = '1984';
    usuarioBusca = '17ef7bf2';

    if verificarNoBloom(livroBuscaID, BF_livros, numHashes)
        disp(['O livro com ID "', livroBuscaID, '" já está registrado no sistema.']);
    else
        disp(['O livro com ID "', livroBuscaID, '" não está registrado.']);
    end

    if verificarNoBloom(livroBuscaTitulo, BF_livros, numHashes)
        disp(['O livro com título "', livroBuscaTitulo, '" já está registrado no sistema.']);
    else
        disp(['O livro com título "', livroBuscaTitulo, '" não está registrado.']);
    end

    if verificarNoBloom(usuarioBusca, BF_usuarios, numHashes)
        disp(['O usuário com ID "', usuarioBusca, '" já está registrado no sistema.']);
    else
        disp(['O usuário com ID "', usuarioBusca, '" não está registrado.']);
    end
end

% Executar o gerenciador do sistemaa
gerenciarSistema();

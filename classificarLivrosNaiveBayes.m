function generoPredito = classificarLivrosNaiveBayes(titulos, resumos, generosTreino, titulosTest, resumosTest)
    textosTreino = strcat(titulos, " ", resumos);
    textosTest = strcat(titulosTest, " ", resumosTest);

    generosUnicos = unique(generosTreino);
    numGeneros = length(generosUnicos);

    vocabulario = unique(strsplit(lower(join(textosTreino)))); % Normaliza para minúsculas
    numPalavras = length(vocabulario);

    wordCountByGenre = zeros(numGeneros, numPalavras);
    totalWordsByGenre = zeros(numGeneros, 1);

    for g = 1:numGeneros
        genero = generosUnicos{g};
        indicesGenero = strcmp(generosTreino, genero); % Filtrar livros do gênero atual
        textosGenero = join(textosTreino(indicesGenero)); % Combina todos os textos desse gênero
        palavrasGenero = strsplit(lower(textosGenero)); % Divide o texto em palavras

        for p = 1:numPalavras
            wordCountByGenre(g, p) = sum(strcmp(palavrasGenero, vocabulario{p}));
        end

        totalWordsByGenre(g) = sum(wordCountByGenre(g, :));
    end

    %func prob
    function prob = calcularProbabilidade(texto, generoIdx)
        palavrasTexto = strsplit(lower(texto));
        prob = log(sum(strcmp(generosTreino, generosUnicos{generoIdx})) / length(generosTreino)); % P(Gênero)

        for p = 1:length(palavrasTexto)
            palavraIdx = find(strcmp(vocabulario, palavrasTexto{p}));
            if ~isempty(palavraIdx)
                % P(Palavra | Gênero) com Laplace smoothing
                prob = prob + log((wordCountByGenre(generoIdx, palavraIdx) + 1) / ...
                    (totalWordsByGenre(generoIdx) + numPalavras));
            end
        end
    end
    numLivrosTest = length(titulosTest);
    generoPredito = cell(numLivrosTest, 1);

    for i = 1:numLivrosTest
        texto = textosTest{i};
        maxProb = -inf;
        generoEscolhido = "";

        for g = 1:numGeneros
            probGenero = calcularProbabilidade(texto, g);
            if probGenero > maxProb
                maxProb = probGenero;
                generoEscolhido = generosUnicos{g};
            end
        end

        generoPredito{i} = generoEscolhido;
    end
end

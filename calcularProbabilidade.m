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
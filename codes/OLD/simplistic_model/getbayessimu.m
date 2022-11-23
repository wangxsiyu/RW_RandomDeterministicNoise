function bayes = getbayessimu(n, nran, ndet)
    pdni = makedist('Logistic',0, nran);
    pdne = makedist('Logistic',0, ndet);
    bayes.ntot = n * 2;
    bayes.ngame = n;
%     bayes.gameID = [];
    for i = 1:n
%         bayes.gameID([i*2-1 i*2]) = i;
        bayes.gameID(i*2-1) = i;
        bayes.gameID(i*2) = i;
        dni1 = random(pdni);
        dni2 = random(pdni);
        dne = random(pdne);
        bayes.obs(i*2-1) = dne + dni1; %0 + (dne + dni1 > 0);
        bayes.obs(i*2) = dne + dni2; %0 + (dne + dni2 > 0);
    end
end
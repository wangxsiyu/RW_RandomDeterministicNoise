function [p, mus, description] = generate_likelihood()
    lower=1;
    upper=99;
    mus = 1:99;
    sigma=8;
    
    description = "p(m,n) stands for P(X=n|mu= mus(m))";
    
    m = length(mus);
    n= upper-lower+1;
    p = zeros(m, n);
    for i=1:m
        mu = mus(i);
        for j=2:n-1
            p(i,j)= normcdf(lower+j-0.5, mu, sigma) - normcdf(lower+j- 1.5, mu, sigma);
        end
        p(i,1) = normcdf(lower+0.5, mu, sigma);
        p(i,n) = 1 - normcdf(upper - 0.5, mu, sigma);
    end
end
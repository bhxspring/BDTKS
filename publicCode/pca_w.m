function w = pca_w(X)

X = full(X);
COEFF = pca(X);
w = COEFF(:,1);
w = w';

end
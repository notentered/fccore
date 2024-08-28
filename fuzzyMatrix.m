%FUZZYMATRIX Create fuzzy matrix. It extends class 'double'.
%   OBJ = FUZZYMATRIX() Created an empty fuzzy matrix.
%
%   A fuzzy matrix is a matrix which elements are in [0,1] interval. 
%
%   OBJ = FUZZYMATRIX(MATRIX) Creates a fuzzy matrix from a double matrix.
%   Checks if all elements of the double matrix are in [0,1] interval. If not
%   raise an error.
%
%   OBJ = FUZZYMATRIX(X,Y) Create a zero filled matrix with dimensions XxY. 
%
%   Methods
%   -------
%   Type "methods fuzzyMatrix" to see a list of the methods. This class
%   extends class double, so its methods will display as well. Specific or
%   overridden methods for this class are:
%   plus, minus, fcompose, maxmin, minmax, maxprod, minalpha, maxepsilon,
%   mindiamond, godel, goguen, lukasiewicz, is_lincomb, is_linindep.
%
%   For more information about a particular method, type
%   "help fuzzyMatrix/methodname" at the command line.
%
%   Example 1
%   ---------
%   Create two fuzzy matrices with random values and maxmin them.
%
%   a = fuzzyMatrix(rand(5)); b = fuzzyMatrix(rand(5));
%   c = maxmin(a,b);
%
%   Example 2
%   ---------
%   Check if a set of vectors (columns in a fuzzmy matrix) is maxmin linear
%   independent.
%   
%   is_linindep(a,'maxmin')
%
%   References
%   ----------
%   1. K. Peeva, Zl. Zahariev, Software for Testing Linear Dependence in
%   Fuzzy Algebra, Second International Scientific Conference Computer
%   Science, Chalkidiki, 30 Sept -2 Oct 2005, ISBN 954 438 526 6, part I,
%   pp 294-299, 2005.
%   
%   2. K. Peeva, Zl. Zahariev, Linear dependence in fuzzy algebra,
%   Proceedings of 31th International Conference AMÅE, Sozopol June 2005
%   Softrade, Sofia 2006, ISBN 10: 954-334-032-3, pp. 71-83.
%   
%   3. K. Peeva, Zl. Zahariev, Software for Testing Linear Dependence in
%   Fuzzy Algebra, Second International Scientific Conference Computer
%   Science, Chalkidiki, 30 Sept -2 Oct 2005, ISBN 954 438 526 6, part I,
%   pp 294-299, 2005.
%   
%   4. Z. Zahariev, “Solving Max-min Relational Equations. Software and
%   Applications”, in International conference on Applications of
%   Mathematics in Engineering and Economics, June 2008, Sozopol, Bulgaria,
%   December 2008, pp 516-523.
%   
%   5. Z. Zahariev, Software package and API in MATLAB for working with
%   fuzzy algebras, In International Conference „Applications of
%   Mathematics in Engineering and Economics (AMEE'09)”, AIP Conference
%   Proceedings, vol. 1184, G. Venkov, R. Kovatcheva, V. Pasheva (eds.)
%   American Institute of Physics, ISBN 978-0-7354-0750-9, 2009, 434-350.
classdef fuzzyMatrix < double
    methods

        function obj = fuzzyMatrix(varargin)
            %Constructor for fuzzyMatrix.
            % 
            %Automatically clamps all the values to the [0,1] interval.
            %NaN valies are clamped to 0.
            %
            %If called with no parameters it creates an empty fuzzyMatrix.
            %If called with one parameter it should be a matrix.
            %If called with two parameters it creates zero filled
            %   fuzzyMatrix with the specified dimentions.
            switch nargin
                case 0
                    data = [];
                case 1 
                    data = min(max(varargin{1}, 0), 1);
                otherwise
                    data = zeros(varargin{1}, varargin{2});
            end
            
            obj = obj@double(data);
        end

        function result = eq(a, b)
            % Custom eq (==) for fuzzyMatrix using EPS tolerance
            result = abs(double(a) - double(b)) <= eps;
        end

        function result = isequal(a, b)
            % Custom isequal for fuzzyMatrix using EPS tolerance
            result = all(a == b, 'all');
        end

        function result = isequaln(a, b)
            % Custom isequaln for fuzzyMatrix using EPS tolerance
            result = isequal(a, b);
        end

        function result = plus(a,b)
            %Override the default plus method from the double class.
            result = fuzzyMatrix(plus@double(a,b));
        end

        function result = minus(a,b)
            %Override the default minus method from the double class.
            result = fuzzyMatrix(minus@double(a,b));
        end
        
        function result = fcompose(a,b,op1,op2)
            %A general composing method. It composes two fuzzy matrices
            %with two operations.
            %Example: fcompose(a,b,'max','min');
            a = double(a); b = double(b);
            if (size(a,2) == size(b,1))
                result = zeros(size(a,1),size(b,2));
                for i=1:size(a,1)
                    for j=1:size(b,2)
                        result(i,j) = feval(op1,fuzzyMatrix(feval(op2,fuzzyMatrix(a(i,:)),fuzzyMatrix(b(:,j)'))));
                    end
                end
                result = fuzzyMatrix(result);
            else
                error('fuzzyMatrix:DimensionMismatch', 'Inner matrix dimensions must agree.');
            end
        end
        
        function result = not(a)
            %Implements 'fuzzy negation'
            result = 1-a;
        end 

        function result = maxmin(a,b)
            %Implements 'maxmin' composition.
            result = fcompose(a,b,'max','min');
        end

        function result = minmax(a,b)
            %Implements 'minmax' composition.
            result = fcompose(a,b,'min','max');
        end

        function result = maxprod(a,b)
            %Implements 'maxproduct' composition.
            result = fcompose(a,b,'max','times');
        end

        function result = minalpha(a,b)
            %Implements 'minalpha' composition.
            result = fcompose(a,b,'min','falpha');
        end

        function result = godel(a,b)
            %Implements 'godel' composition.
            result = minalpha(a,b);
        end

        function result = maxepsilon(a,b)
            %Implements 'maxepsilon' composition.
            result = fcompose(a,b,'max','fepsilon');
        end

        function result = mindiamond(a,b)
            %Implements 'mindiamond' composition.
            result = fcompose(a,b,'min','fdiamond');
        end

        function result = goguen(a,b)
            %Implements 'goguen' composition.
            result = mindiamond(a,b);
        end

        function result = lukasiewicz(a,b)
            %Implements 'lukasiewicz' composition.
            result = fcompose(a,b,'min','fimpl');
        end

        function result = maxlukasiewicz(a,b)
            %Implements  'max - lukasiewicz' composition.
            result = fcompose(a,b,'max','ftnorml');
        end

        function result = minprobabilistic(a,b)
            %Implements  'min - probabilistic sum' composition.
            result = fcompose(a,b,'min','fprobabilisticsum');
        end

        function result = minbounded(a,b)
            %Implements  'min - bounded sum' composition.
            result = fcompose(a,b,'min','fboundedsum');
        end

        function result = maxdelta(a,b)
            %Implements  'max - delta' composition.
            result = fcompose(a,b,'max','fdelta');
        end

        function result = maxgama(a,b)
           %Implements  'max - gama' composition.
            result = fcompose(a,b,'max','fgama');
        end

        function result = is_lincomb(type,a,b)
            %Check for a linear combinations according some composition.
            %First parameter should be composition (ex: 'maxmin' or
            %'minmax');
            %Second is a matrix;
            %Third can be a number or a vector (matrix with only one
            %column). If number (n) than the n-th column is checked against
            %all the other. If vector then the vector is checked against
            %the matrix;
            a = double(a); b = double(b);
            if length(b)==1
                col = a(:,b);
                a(:,b) = [];
                b=col;
            else
                dim = size(b)==1;
                if ~any(dim)
                    error('Third parameter cannot be a matrix. Only numbers or verctors are allowed.')
                elseif dim(1)==1
                    b = b';
                end
            end
            s = fuzzySystem(type,fuzzyMatrix(a),fuzzyMatrix(b));
            s.solve_inverse;
            result = s.x;
        end

        function result = is_linindep(a, type, full)
            %Check if a set of vectors (matrix) is linear independent.
            %First parameter is a fuzzyMatrix, second is a compositions.
            %Third parameter is optional and boolean. If false (default)
            %this method return only true or false. If true, the method
            %return a vector with the exact combination if there is aa
            %such.
            if (nargin >=3) && (full == true)
                depvectors = zeros(1,size(a,2));
                ii = 1;
            else
                full = false;
            end
            for i=1:size(a,2)
                sol=is_lincomb(type,a,i);
                
                if sol == false
                    result = false;
                    return;
                end
                
                if sol.exist
                    if full == true
                        depvectors(ii) = true;
                        ii = ii + 1;
                    else
                        result = false;
                        return;
                    end
                end
            end
            result = depvectors(1:ii);
        end

    end
end
classdef fuzzyMatrixTest < matlab.mock.TestCase

    methods (Test)
        
        function testEmptyInitialization(testCase)
            % Test initialization without a matrix
            obj = fuzzyMatrix();
            
            testCase.verifyEqual(double(obj), []);
        end

        function testMatrixInitialization(testCase)
            % Test initialization with a valid matrix
            data = [0.2, 0.5; 0.3, 0.7];
            obj = fuzzyMatrix(data);
            
            testCase.verifyEqual(double(obj), data);
        end

        function testZeroMatrixInitialization(testCase)
            % Test initialization with dimensions to create a zero matrix
            i=2; j=3;
            obj = fuzzyMatrix(i, j);
            
            testCase.verifyEqual(double(obj), zeros(i, j));
        end

        function testOutOfRangeInitialization(testCase)
            % Test initialization with a matrix having out-of-range values
            data = [0.2, 1.5; 0.3, -0.1];
            expected = [0.2, 1; 0.3, 0];
            obj = fuzzyMatrix(data);
            
            testCase.verifyEqual(double(obj), expected);
        end

        function testNanInitialization(testCase)
            % Test initialization with a valid matrix with NaN values
            data =     [nan, 0.5; 0.3, nan];
            expected = [  0, 0.5; 0.3,   0];
            obj = fuzzyMatrix(data);
            
            testCase.verifyEqual(double(obj), expected);
        end

        function testEqMethod(testCase)
            a = fuzzyMatrix([0.5, 0.7; 0.3, 0.9]);

            % Test equality with no tolerance
            b = fuzzyMatrix([0.5, 0.7; 0.3, 0.9]);
            actual = (a == b);
            expected = logical([1, 1; 1, 1]);
            testCase.verifyTrue(all(all(actual == expected)));

            % Test equality with small tolerance difference
            b = fuzzyMatrix([0.5 + eps, 0.7; 0.3, 0.9]);
            actual = (a == b);
            expected = logical([1, 1; 1, 1]);
            testCase.verifyTrue(all(all(actual == expected)));
        
            % Test equality where one element is outside the tolerance
            b = fuzzyMatrix([0.5 + 2*eps, 0.7; 0.3, 0.9]);
            actual = (a == b);
            expected = logical([0, 1; 1, 1]);
            testCase.verifyTrue(all(all(actual == expected)));
        end

        function testIsequalMethod(testCase)
            a = fuzzyMatrix([0.5, 0.7; 0.3, 0.9]);

            % Test equal matrices with no tolerance
            b = fuzzyMatrix([0.5, 0.7; 0.3, 0.9]);
            actual = isequal(a, b);
            testCase.verifyTrue(actual);

            % Test equal matrices with small tolerance difference
            b = fuzzyMatrix([0.5 + eps, 0.7; 0.3, 0.9]);
            actual = isequal(a, b);
            testCase.verifyTrue(actual);
        
            % Test matrices where one element is outside the tolerance
            b = fuzzyMatrix([0.5 + 2*eps, 0.7; 0.3, 0.9]);
            actual = isequal(a, b);
            testCase.verifyFalse(actual);
        end

        function testIsequalnMethod(testCase)
            % Test isequaln behaves as isequal
            a = fuzzyMatrix(rand(2));
            b = fuzzyMatrix(rand(2));
            testCase.verifyTrue(isequaln(a,b) == isequal(a,b));
        end

        function testPlusOperationOverflow(testCase)
            % Test the plus operation ensuring values don't exceed 1
            a = fuzzyMatrix([0.8, 0.9; 0.3, 0.1]);
            b = fuzzyMatrix([0.5, 0.4; 0.5, 0.6]);
            expected = fuzzyMatrix([1, 1; 0.8, 0.7]);
            
            testCase.verifyEqual(a + b, expected);
        end

        function testMinusOperationOverflow(testCase)
            % Test the minus operation ensuring values remain above 0
            a = fuzzyMatrix([0.8, 0.9; 0.3, 0.1]);
            b = fuzzyMatrix([0.5, 0.4; 0.5, 0.6]);
            expected = fuzzyMatrix([0.3, 0.5; 0, 0]);
            
            testCase.verifyEqual(a-b, expected);
        end

        function testFcomposeDimensionsMismatch(testCase)
            % Test fcompose with incompatible input matrices
            a = fuzzyMatrix(rand(3, 4));
            b = fuzzyMatrix(rand(5, 3));
            testCase.verifyError(@() fcompose(a, b, 'max', 'min'), 'fuzzyMatrix:DimensionMismatch');
        end

        function testFcomposeInIsolation(testCase)
            % Test fcompose for calling the correct operations on execution
            import matlab.mock.TestCase
            import matlab.mock.actions.AssignOutputs

            [spyBroker, brokerBehavior] = createMock(testCase, 'AddedMethods', {'max', 'min'});
            when(withAnyInputs(brokerBehavior.max), AssignOutputs(0.9));
            when(withAnyInputs(brokerBehavior.min), AssignOutputs(0.1));
            
            a = fuzzyMatrix(rand(3, 4));
            b = fuzzyMatrix(rand(4, 2));
            result = fcompose(a, b, @spyBroker.max, @spyBroker.min);
            
            testCase.verifyCalled(withAnyInputs(brokerBehavior.max));
            testCase.verifyCalled(withAnyInputs(brokerBehavior.min));
            testCase.verifyInstanceOf(result, 'fuzzyMatrix');
        end

    end

end

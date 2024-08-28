classdef fuzzyMatrixCompositionsTest < matlab.unittest.TestCase

    properties
        fixture
    end

    properties (Constant)
        compositionTests = {
            @maxmin, 'ExamplesMaxMin', 'expectedMaxMin';
            @minmax, 'ExamplesMinMax', 'expectedMinMax';
            @maxprod, 'ExamplesMaxProduct', 'expectedMaxProduct';
            @minalpha, 'ExamplesMinAlpha', 'expectedMinAlpha';
            @godel, 'ExamplesGodel', 'expectedGodel';
            @maxepsilon, 'ExamplesMaxEpsilon', 'expectedMaxEpsilon';
            @mindiamond, 'ExamplesMinDiamond', 'expectedMinDiamond';
            @goguen, 'ExamplesGoguen', 'expectedGoguen';
            @lukasiewicz, 'ExamplesLukasiewicz', 'expectedLukasiewicz';
            @maxlukasiewicz, 'ExamplesMaxLukasiewicz', 'expectedMaxLukasiewicz';
            @minprobabilistic, 'ExamplesMinProbabilistic', 'expectedMinProbabilistic';
            @minbounded, 'ExamplesMinBounded', 'expectedMinBounded';
            @maxdelta, 'ExamplesMaxDelta', 'expectedMaxDelta';
            @maxgama, 'ExamplesMaxGama', 'expectedMaxGama';
        };
    end

    methods (TestClassSetup)
        function setupFixture(testCase)
            testCase.fixture = testCase.applyFixture(fuzzyMatrixCompositionFixtures);
        end
    end

    methods (Test)
        function testFuzzyCompositionsLiterature(testCase)
            for testIdx = 1:size(testCase.compositionTests, 1)
                compositionFunc = testCase.compositionTests{testIdx, 1};
                examplesField = testCase.compositionTests{testIdx, 2};

                examples = testCase.fixture.(examplesField);

                for i = 1:length(examples)
                    example = examples{i};
                    result = compositionFunc(example.a, example.b);

                    testCase.verifyEqual(result, example.expected);
                end
            end
        end
       
        function testRandomExamples(testCase)
            for testIdx = 1:size(testCase.compositionTests, 1)
                compositionFunc = testCase.compositionTests{testIdx, 1};
                expectedField = testCase.compositionTests{testIdx, 3};

                for i = 1:length(testCase.fixture.RandomExamples)
                    example = testCase.fixture.RandomExamples{i};
                    result = compositionFunc(example.a, example.b);
                    testCase.verifyEqual(double(result), double(example.(expectedField)), 'AbsTol', 1e-6);
                end
            end
        end
    end

end

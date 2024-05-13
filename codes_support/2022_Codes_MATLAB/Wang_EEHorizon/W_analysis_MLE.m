classdef W_analysis_MLE < handle
    properties
    end
    methods(Static)
        function [xfit, negLLbest] = MLEfit_choicecurve(choice, dR, additionalX, ...
                isbias, islapserate, ...
                X0struct, LBstruct, UBstruct, ...
                nX0, priorFlag, isdisplay)
            % need to implement priorFlag
            % noise may need to be multiplied by sqrt(2)
            if ~exist('nX0', 'var') || isempty(nX0) % number of initial points
                nX0 = 1;
            end
            if ~exist('priorFlag', 'var') || isempty(priorFlag)
                priorFlag = false;
            end
            if exist('isdisplay', 'var') && strcmp(isdisplay, 'on')
                options = optimoptions('fmincon', 'Display', 'on');
            else
                options = optimoptions('fmincon', 'Display', 'off');
            end
            problems.options = options;
            % X0, LB, UB should be in the order
            % ...... [noise, w_bias, w_additionalX, lapse1, lapse2]
            if ~isfield(X0struct, 'noise')
                X0struct.noise = [1];
                LBstruct.noise = [0];
                UBstruct.noise = [100];
            end
            if ~isfield(X0struct, 'bias')
                if isbias
                    X0struct.bias = 0;
                    LBstruct.bias = -100;
                    UBstruct.bias = 100;
                else
                    X0struct.bias = [];
                    LBstruct.bias = [];
                    UBstruct.bias = [];
                end
            end
            if ~isfield(X0struct, 'additionalX')
                X0struct.additionalX = [];
                LBstruct.additionalX = [];
                UBstruct.additionalX = [];
            end
            if ~isfield(X0struct, 'lapse')
                if  isempty(islapserate) || all(islapserate == 0)
                    X0struct.lapse = [];
                    LBstruct.lapse = [];
                    UBstruct.lapse = [];
                elseif all(islapserate == [1 0]) || all(islapserate == [0 1])
                    X0struct.lapse = [0.1];
                    LBstruct.lapse = [0];
                    UBstruct.lapse = [1];
                else
                    X0struct.lapse = [0.1 0.1];
                    LBstruct.lapse = [0 0];
                    UBstruct.lapse = [1 1];
                end
            end
            X0 = [X0struct.noise, X0struct.bias, X0struct.additionalX, X0struct.lapse];
            LB = [LBstruct.noise, LBstruct.bias, LBstruct.additionalX, LBstruct.lapse];
            UB = [UBstruct.noise, UBstruct.bias, UBstruct.additionalX, UBstruct.lapse];
            negLLbest = Inf;
            xfit = [];
            for repi = 1:nX0
                % needs to implement multiple initial point
                problems.x0 = X0;
                problems.LB = LB;
                problems.UB = UB;
                problems.solver = 'fmincon';
                if isempty(islapserate) || all(islapserate == 0)
                    if isbias
                        problems.objective = @(x)-W_analysis_MLE.logLL_choicecurve(choice, dR, x(1), x(2), additionalX, x(3:end), 0, 0, priorFlag);
                    else
                        problems.objective = @(x)-W_analysis_MLE.logLL_choicecurve(choice, dR, x(1), 0, additionalX, x(2:end), 0, 0, priorFlag);
                    end
                    [xfit_raw, negLL] = fmincon(problems);
                    if negLL < negLLbest
                        negLLbest = negLL;
                        xfit.noise = xfit_raw(1);
                        if isbias
                            xfit.bias = xfit_raw(2);
                            xfit.additionalX = xfit_raw(3:end);
                        else
                            xfit.additionalX = xfit_raw(2:end);
                        end
                    end
                elseif all(islapserate == [1 0])
                    if isbias
                        problems.objective = @(x)-W_analysis_MLE.logLL_choicecurve(choice, dR, x(1), x(2), additionalX, x(3:end-1), x(end), 0, priorFlag);
                    else
                        problems.objective = @(x)-W_analysis_MLE.logLL_choicecurve(choice, dR, x(1), 0, additionalX, x(2:end-1), x(end), 0, priorFlag);
                    end
                    [xfit_raw, negLL] = fmincon(problems);
                    if negLL < negLLbest
                        negLLbest = negLL;
                        xfit.lapse1 = xfit_raw(end);
                        xfit.noise = xfit_raw(1);
                        if isbias
                            xfit.bias = xfit_raw(2);
                            xfit.additionalX = xfit_raw(3:end-1);
                        else
                            xfit.additionalX = xfit_raw(2:end-1);
                        end
                    end
                elseif all(islapserate == [0 1])
                    if isbias
                        problems.objective = @(x)-W_analysis_MLE.logLL_choicecurve(choice, dR, x(1), x(2), additionalX, x(3:end-1), 0, x(end), priorFlag);
                    else
                        problems.objective = @(x)-W_analysis_MLE.logLL_choicecurve(choice, dR, x(1), 0, additionalX, x(2:end-1), 0, x(end), priorFlag);
                    end
                    [xfit_raw, negLL] = fmincon(problems);
                    if negLL < negLLbest
                        negLLbest = negLL;
                        xfit.lapse2 = xfit_raw(end);
                        xfit.noise = xfit_raw(1);
                        if isbias
                            xfit.bias = xfit_raw(2);
                            xfit.additionalX = xfit_raw(3:end-1);
                        else
                            xfit.additionalX = xfit_raw(2:end-1);
                        end
                    end
                else
                    if isbias
                        problems.objective = @(x)-W_analysis_MLE.logLL_choicecurve(choice, dR, x(1), x(2), additionalX, x(3:end-2), x(end-1), x(end), priorFlag);
                    else
                        problems.objective = @(x)-W_analysis_MLE.logLL_choicecurve(choice, dR, x(1), 0, additionalX, x(2:end-2), x(end-1), x(end), priorFlag);
                    end
                    [xfit_raw, negLL] = fmincon(problems);
                    if negLL < negLLbest
                        negLLbest = negLL;
                        xfit.lapse1 = xfit_raw(end-1);
                        xfit.lapse2 = xfit_raw(end);
                        xfit.noise = xfit_raw(1);
                        if isbias
                            xfit.bias = xfit_raw(2);
                            xfit.additionalX = xfit_raw(3:end-2);
                        else
                            xfit.additionalX = xfit_raw(2:end-2);
                        end
                    end
                end
            end
        end
        function [LL] = logLL_choicecurve(choice, dR, noise, bias, additionalX, w_additionalX, ...
                lapse1, lapse2, priorFlag)
            if ~isempty(additionalX)
                q = dR + additionalX * w_additionalX' + bias;
            else
                q = dR + bias;
            end
            p_value = 1./(1 + exp(-q/noise));
            p = p_value * (1-lapse1-lapse2) + lapse1;
            p(choice == 0) = 1 - p(choice == 0);
            logp = log(p);
            logp = logp(~isnan(logp));
            if any(abs(logp) == Inf)
                logp = logp(abs(logp) < Inf); % this may lead to issues, need to look into this later
%                 W.warning('undefined at initial point, remove -Inf');
            end
            LL = sum(logp);
        end
    end
end
%% Trapezoidal Velocity Profile Function 
        %Input: (q1,q2,steps)
        %Output: qMatrix
        function qFunctionMatrix = TVP(q1,q2,steps)
            s = lspb(0,1,steps); % First, create the scalar function
            qFunctionMatrix = nan(steps,numel(q1)); % Create memory allocation for variables
                 for i = 1:1:steps
                     qFunctionMatrix(i,:) = (1-s(i))*q1 + s(i)*q2;    % Generate interpolated joint angles
                 end
        end
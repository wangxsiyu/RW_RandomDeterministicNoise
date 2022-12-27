classdef W < W_tools & ...
            W_files & ...
            W_import & ...
            W_behavior & ...
            W_preprocess & ...
            W_analysis & ...
            W_neuro
    properties
    end
    methods(Static)
        function library(str, is_subfolder)
            arguments
                str string = "";
                is_subfolder logical = false;
            end
            mdir = fileparts(W.wangpath);
            mdir = fullfile(mdir,'MATLAB_packages',str);
            if is_subfolder
                addpath(genpath(mdir));
            else
                addpath(mdir);
            end
            W.print('loaded library %s:%s', str, mdir);
        end
        function library_wang(str, is_subfolder)
            arguments
                str string = "";
                is_subfolder logical = false;
            end
            mdir = fileparts(W.wangpath);
            mdir = fullfile(mdir, str);
            if is_subfolder
                addpath(genpath(mdir));
            else
                addpath(mdir);
            end
            W.print('loaded library %s:%s', str, mdir);
        end
        function out = wangpath()
            out = fileparts(mfilename('fullpath')); 
        end
    end
end
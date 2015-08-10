classdef Feature
    methods (Abstract)
        features = extract_low_level_features(obj, aligned_shapes)
    end
end
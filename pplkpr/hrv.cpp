#include "hrv.h"

#include <vector>
#include <limits>
#include <cmath>
using namespace std;

namespace hrv {
    float sum(const vector<float>& data) {
        float sum = 0;
        for(int i = 0; i < data.size(); i++) {
            float x = data[i];
            sum += x;
        }
        return sum;
    }
    
    float mean(const vector<float>& data) {
        if(data.size() == 0) {
            return 0;
        }
        return sum(data) / data.size();
    }
    
    int countGreater(const vector<float>& data, float cutoff) {
        int count = 0;
        for(int i = 0; i < data.size(); i++) {
            float x = data[i];
            if(x > cutoff) {
                count++;
            }
        }
        return count;
    }
    
    vector<float> sq(const vector<float>& data) {
        int n = (int)data.size();
        vector<float> results(n);
        for(int i = 0; i < n; i++) {
            float x = data[i];
            results[i] = (x * x);
        }
        return results;
    }
    
    float max(const vector<float>& data) {
        if(data.size() == 0) {
            return 0;
        }
        float max = -numeric_limits<float>::infinity();
        for(int i = 0; i < data.size(); i++) {
            float x = data[i];
            if(x > max) {
                max = x;
            }
        }
        return max;
    }
    
    float min(const vector<float>& data) {
        if(data.size() == 0) {
            return 0;
        }
        float min = +numeric_limits<float>::infinity();
        for(int i = 0; i < data.size(); i++) {
            float x = data[i];
            if(x < min) {
                min = x;
            }
        }
        return min;
    }
    
    float range(const vector<float>& data) {
        return max(data) - min(data);
    }
    
    vector<float> differences(const vector<float>& data, float subtrahend) {
        vector<float> results;
        for(int i = 0; i < data.size(); i++) {
            float x = data[i];
            results.push_back(x - subtrahend);
        }
        return results;
    }
    
    float standardDeviation(const vector<float>& data) {
        if(data.size() == 0) {
            return 0;
        }
        float dataMean = mean(data);
        float dataCount = data.size();
        return sqrt(sum(sq(differences(data, dataMean))) / dataCount);
    }
    
    vector<float> successiveDifferences(const vector<float>& data, int lag = 1) {
        int n = (int)data.size() - lag;
        vector<float> results(n);
        for(int i = 0; i < n; i++) {
            results[i] = data[i + lag] - data[i];
        }
        return results;
    }
    
    vector<float> successiveRatios(const vector<float>& data, int lag = 1) {
        int n = (int)data.size() - lag;
        vector<float> results(n);
        for(int i = 0; i < n; i++) {
            results[i] = data[i + lag] / data[i];
        }
        return results;
    }
    
    float MSD(const vector<float>& data) {
        return mean(successiveDifferences(data));
    }
    
    float SDNN(const vector<float>& data) {
        return standardDeviation(data);
    }
    
    float RMSSD(const vector<float>& data, int lag = 1) {
        return sqrt(sum(sq(successiveDifferences(data, lag))));
    }
    
    float SDSD(const vector<float>& data, int lag = 1) {
        return standardDeviation(successiveDifferences(data, lag));
    }
    
    float NN50(const vector<float>& data) {
        return countGreater(successiveDifferences(data), 50);
    }
    
    float pNN50(const vector<float>& data) {
        return countGreater(successiveDifferences(data), 50) / (float) data.size();
    }
    
    float NN20(const vector<float>& data) {
        return countGreater(successiveDifferences(data), 20);
    }
    
    float pNN20(const vector<float>& data) {
        return countGreater(successiveDifferences(data), 20) / (float) data.size();
    }
    
    float EBC(const vector<float>& data) {
        return range(data);
    }
    
    vector<double> buildMetrics(const vector<float>& rrms) {
        vector<double> metrics(8);
        
        metrics[0] = (mean(rrms));
        metrics[1] = (MSD(rrms));
        metrics[2] = (SDNN(rrms));
        metrics[3] = (RMSSD(rrms));
        metrics[4] = (SDSD(rrms));
        metrics[5] = (EBC(rrms));
        metrics[6] = (pNN50(rrms));
        metrics[7] = (pNN20(rrms));
        
        return metrics;
    }
}
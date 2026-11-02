"""Real numerical contracts; no mocked explainer or training in explain_model."""
import importlib.util
import sys
from pathlib import Path
import numpy as np
import pandas as pd
from sklearn.linear_model import LinearRegression

ROOT = Path(sys.argv[1])

def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

def test_shap():
    module = load('explain_model', ROOT/'shap-explanation/code/explain_model.py')
    x = pd.DataFrame({'a': [0., 1., 2., 3.], 'b': [2., 0., 1., 4.]})
    model = LinearRegression().fit(x, 2*x.a-3*x.b+4)
    before = x.copy(deep=True)
    coefs = model.coef_.copy()
    result = module.explain_model(model, x, x, explainer_kind='linear', top_n=2)
    expected = (x-x.mean()).to_numpy()*np.array([2., -3.])
    np.testing.assert_allclose(result['values'], expected, atol=1e-10)
    np.testing.assert_allclose(result['summary']['shap'], [3.75, 2.0], atol=1e-10)
    np.testing.assert_allclose(result['summary']['percent'].sum(), 100.)
    assert len(result['samples']) == 8
    pd.testing.assert_frame_equal(before, x)
    np.testing.assert_array_equal(coefs, model.coef_)
    try:
        module.explain_model(model, x, x[['b','a']], explainer_kind='linear')
    except ValueError:
        pass
    else:
        raise AssertionError('Mismatched feature order was accepted')
    print('PASS SHAP analytical linear solution; tables; no input/model mutation; feature order guard')

def test_regression():
    module = load('regression_summary', ROOT/'regression-resampling-evaluation/code/summarize_predictions.py')
    frame = pd.DataFrame(dict(sample_id=['a','b','c','d'], model=['m']*4,
        repeat=[1]*4, fold=[1,1,2,2], y_true=[0.,2.,4.,6.],
        y_pred=[1.,1.,4.,8.], split_design=['kfold']*4))
    before = frame.copy(deep=True)
    result = module.summarize(frame, ['a','b','c','d'])
    np.testing.assert_allclose(result.RMSE, [1., np.sqrt(2.)])
    np.testing.assert_allclose(result.MAE, [1.,1.])
    np.testing.assert_allclose(result.R2, [0.,-1.])
    assert np.isnan(result.r.iloc[0])
    pd.testing.assert_frame_equal(before, frame)
    try:
        module.summarize(frame, ['a','b','c'])
    except ValueError:
        pass
    else:
        raise AssertionError('Incomplete coverage was accepted')
    print('PASS regression hand-derived metrics; constant prediction r; no mutation; heldout coverage')

if __name__ == '__main__':
    test_shap()
    test_regression()

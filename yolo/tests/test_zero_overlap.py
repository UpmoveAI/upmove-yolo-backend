"""
Test for zero-overlap RectangleLabels behavior.
When Label Studio config labels have zero exact overlap with YOLO model labels,
the /predict endpoint should return HTTP 200 with result=[] and model_version.
"""

import pytest
import json

from label_studio_ml.utils import compare_nested_structures
from .test_common import client


label_config_zero_overlap = """
<View>
  <Image name="image" value="$image"/>
  <RectangleLabels name="label" toName="image" model_score_threshold="0.25">
    <Label value="NonExistentLabel1" background="green"/>
    <Label value="NonExistentLabel2" background="blue" predicted_values="fake_label1, fake_label2"/>
  </RectangleLabels>
</View>
"""

task_zero_overlap = {
    "data": {
        "image": "https://s3.amazonaws.com/htx-pub/datasets/mmdetection-ml-test/001bebecea382500.jpg"
    }
}

expected_zero_overlap = [
    {
        "model_version": "yolo",
        "result": [],
        "score": 0.0,
    }
]


def test_rectanglelabels_zero_overlap_predict(client):
    """Test that zero-overlap config returns HTTP 200 with empty result."""
    data = {"schema": label_config_zero_overlap, "project": "42"}
    response = client.post(
        "/setup", data=json.dumps(data), content_type="application/json"
    )
    assert response.status_code == 200, "Error while setup: " + str(response.content)

    data = {"tasks": [task_zero_overlap], "label_config": label_config_zero_overlap}
    response = client.post(
        "/predict", data=json.dumps(data), content_type="application/json"
    )
    assert response.status_code == 200, "Error while predict: " + str(response.content)
    
    result = response.json
    assert "results" in result, "Missing 'results' in response"
    assert len(result["results"]) == 1, "Expected 1 prediction"
    
    prediction = result["results"][0]
    assert prediction["model_version"] == "yolo", "Missing or incorrect model_version"
    assert prediction["result"] == [], "Expected empty result list for zero-overlap"
    assert "score" in prediction, "Missing score field"
    # score should be 0 when there are no regions (avg_score calculation with empty list)
    assert prediction["score"] == 0.0, "Expected score of 0.0 for zero-overlap"


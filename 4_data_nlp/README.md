# Extraction of Primary Disorders from ED Clinical Notes

data/clinical_notes.csv contains synthetic free-text ED triage notes. Describe (or implement) how you would extract primary disorder as structured information from these notes using an NLP or LLM approach.

## Implementation

Primary disorders were extracted from clinical notes using a NLP pipeline built with **SciSpaCy** model `en_ner_bc5cdr_md`, using a combination of rule-based pattern matching and named entity recognition to identify of disease entities in clinical text.

Please see workbook `NLP.ipynb` for the pipeline.

#### Approach

Rule-based pattern matching can detect text patterns typically associated with chief complaints or presentation mentions.
After text patterns were identified, the biomedical NER model was used to detect entities within the texts.

### Pattern Design

**1. Complaint headers followed by disease entities**

This pattern captures diseases that appear immediately after complaint headers.

```
[cc/complaint/present] + punctuation + DISEASE (+ optional "and" DISEASE)
```

Example: CC: chest pain

**2. Complaint headers with words before the disease**

This captures text with words between the header and the disease entity.

```
[cc/complaint/present] + words + DISEASE (+ optional second disease)
```

Example: chief complaint of severe headache


**3. Complaint headers followed by 1-3 words**

This captures words that describes symptoms and could not be identified by the model as a disease entity.

```
[cc/complaint/present] + punctuation + 1–3 words
```

Example: CC: urinary symptoms


**4. Complaint headers followed by words then duration**

```
[cc/complaint/present] + words + ("x" or "since")
```

Example: CC headache x 2 days


**5. Past medical history with disease**

This pattern identifies diseases in the past medical history section, so they can be excluded further down the pipeline.

```
[pmh/history] + punctuation + DISEASE
```

Example: PMH: diabetes


**6. Past medical history with words before disease**

These matches are also excluded further down the pipeline.

```
[pmh/history] + words + DISEASE
```

Example: past medical history significant hypertension


**7. Disease followed by punctuation (excluding ':')**

This rule takes into account cases whether the compliant headers are not present.

```
DISEASE + punctuation (not ":")
```

Example:
asthma.

**8. Short word sequences followed by punctuation (excluding ':')**

This rule takes into account cases whether the compliant headers are not present, and the named entity is not recognisable as a disease by the model.

```
1–4 words + punctuation (excluding colon)
```

Example: urinary symptoms.

---
## 📌 성능 검증 및 평가
- **검증 방법:** 
- OPENAI를 이용한 실제 법령에 명시된 내용에서 Q-A쌍 10개 추출 후 LLM의 답변과 정확성, 관련성, 신뢰성 등 평가 지표 설정 및 측정
- 홈텍스 내의 질의응답 게시판과 LLM모델의 답변 비교
- cos 유사도를 통한 질문과 LLM답변간의 문백 유사도 검증
- bleu스코어 및 rouge 스코어 검증
- **결과:** 시스템이 제공하는 답변의 정확성과 일관성을 지속적으로 모니터링하여 시스템을 개선

```python
# 평가용 chain  구성
class EvalDatasetSchema(BaseModel):
    user_input:str = Field(..., description="질문(Question)")
    retrieved_contexts:list[str] = Field(..., description="LLM이 답변할 때 참조할 context")
    reference: str = Field(..., description="정답(ground truth)")

jsonparser = JsonOutputParser(pydantic_object=EvalDatasetSchema)

qa_prompt_template = PromptTemplate.from_template(
    template=dedent("""
        당신은 RAG 평가를 위해 질문과 정답 쌍을 생성하는 인공지능 비서입니다.
        다음 [Context] 에 문서가 주어지면 해당 문서를 기반으로 {num_questions}개의 질문을 생성하세요. 

        질문과 정답을 생성한 후 아래의 출력 형식 GUIDE 에 맞게 생성합니다.
        질문은 반드시 [context] 문서에 있는 정보를 바탕으로 생성해야 합니다. [context]에 없는 내용을 가지고 질문-답변을 절대 만들면 안됩니다.
        질문은 간결하게 작성합니다.
        하나의 질문에는 한 가지씩만 내용만 작성합니다. 
        질문을 만들 때 "제공된 문맥에서", "문서에 설명된 대로", "주어진 문서에 따라" 또는 이와 유사한 말을 하지 마세요.
        정답은 반드시 [context]에 있는 정보를 바탕으로 작성합니다. 없는 내용을 추가하지 않습니다.
        질문과 답변을 만들고 그 내용이 [context] 에 있는 항목인지 다시 한번 확인합니다.
        생성된 질문-답변 쌍은 반드시 dictionary 형태로 정의하고 list로 묶어서 반환해야 합니다.
        질문-답변 쌍은 반드시 {num_questions}개를 만들어 주십시오.
                    
        출력 형식: {format_instructions}

        [Context]
        {context}
        """
    ),
    partial_variables={"format_instructions":jsonparser.get_format_instructions()}
)

# 데이터셋 생성 체인 구성
model = ChatOpenAI(model="gpt-4o")
dataset_generator_chain = qa_prompt_template | model | jsonparser

# 평가 데이터로 사용할 5개의 context 추출
total_samples = 5

idx_list = list(range(len(all_documents)))
random.shuffle(idx_list)

eval_context_list = []
while len(eval_context_list) < total_samples:
    idx = idx_list.pop()
    context = all_documents[idx].page_content
    if len(context) > 100:
        eval_context_list.append(context)

# 전체 context sample들로 qa dataset을 생성
eval_data_list = []
num_questions = 2
for context in eval_context_list:
    _eval_data_list = dataset_generator_chain.invoke(
        {"context":context, "num_questions":num_questions}
    )
    for eval_data in _eval_data_list:
        eval_data['retrieved_contexts'] = [context]
    
    eval_data_list.extend(_eval_data_list)

eval_df = pd.DataFrame(eval_data_list)

context_list = []
response_list = []

for user_input in eval_df['user_input']:
    res = rag_chain.invoke(user_input)
    context_list.append(res['source_context'])
    response_list.append(res['llm_answer'])

eval_df["retrieved_contexts"] = context_list
eval_df["response"] = response_list

eval_dataset = EvaluationDataset.from_pandas(eval_df)

# 평가모델 wrapping
load_dotenv()
model = ChatOpenAI(model= "gpt-4o")
eval_llm = LangchainLLMWrapper(model)
embedding_model = OpenAIEmbeddings(model="text-embedding-3-small")
eval_embedding = LangchainEmbeddingsWrapper(embedding_model)
metrics = [
    LLMContextRecall(llm=eval_llm),
    LLMContextPrecisionWithReference(llm=eval_llm),
    Faithfulness(llm=eval_llm),
    AnswerRelevancy(llm=eval_llm, embeddings=eval_embedding)
]

# BLEU, ROUGE Score 검증
scorer = rouge_scorer.RougeScorer(['rouge1', 'rougeL'])
bleu_score = sentence_bleu([ground_truth.split()], answer.split())
rouge_scores = scorer.score(answer, ground_truth)

# 결과
result = evaluate(dataset=eval_dataset, metrics=metrics)
result.to_pandas()
print(f"BLEU점수:{bleu_score:.2f}")
print(f"Rouge1점수:{rouge_scores['rouge1']}")
print(f"RougeL점수:{rouge_scores['rougeL']}")


```
- 결과<br/>
<img src="https://github.com/SKNETWORKS-FAMILY-AICAMP/SKN06-4th-04Team/blob/main/result_img/q_a_10pair.png"> <br/>

![image](https://github.com/user-attachments/assets/7e546efd-8373-4116-b59d-db3e096ec4f7)


- 결과<br/>
<img src="https://github.com/SKNETWORKS-FAMILY-AICAMP/SKN06-4th-04Team/blob/main/result_img/hometax.png"><br/>
<img src="https://github.com/SKNETWORKS-FAMILY-AICAMP/SKN06-4th-04Team/blob/main/result_img/hometax_response.png"><br/>

답변: 
 취업 전 지출한 월세나 신용카드 결제 금액의 연말정산 공제 여부는 특정 조건에 따라 달라질 수 있습니다.일반적으로 연말정산에서 소득공제는 해당 과세기간 내 소득이 있는 경우에만 공제 가능합니다.따라서, 취업 이전에 소득이 없다면 해당 기간 동안의 지출에 대해서는 소득공제를 받을 수 있는 기준이 충족되지 않을 수 있습니다.
1. 월세 공제: 월세 세액공제는 근로소득이 있는 경우 해당 과세기간에 실제로 납부한 월세에 대해 적용됩니다. 따라서, 취업 전 월세 지출은 공제 대상이 아닐 가능성이 높습니다.
2. 신용카드 공제: 신용카드 사용금액 소득공제는 근로소득이 있는 거주자가 해당 과세연도에 사용한 금액에 대해 적용됩니다.취업 전 사용한 금액은 소득이 없었기 때문에 공제 대상이 아닐 수 있습니다.
각 개인의 상황에 따라 다를 수 있으므로, 정확한 판단을 위해서는 세무 전문가와 상담하거나 국세청의 지침을 확인하는 것이 좋습니다. 이 답변은 세법 관련 정보를 바탕으로 작성되었으며, 구체적인 상황에 따라 전문가의 추가 조언이 필요할 수 있습니다. <br/>
- 결과<br/>
Semantic Similarity: 0.38 <br/><br/>
BLEU점수:0.00 <br/><br/>
Rouge1점수:Score(precision=0.2, recall=0.5, fmeasure=0.28571428571428575) <br/>
RougeL점수:Score(precision=0.2, recall=0.5, fmeasure=0.28571428571428575) <br/>

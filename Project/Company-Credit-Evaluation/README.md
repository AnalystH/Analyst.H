## 프로젝트 소개

### 목적

- 기업신용평가 모델링 (use _Random Forest, Logistic Regression_)
- 기업신용에 중요한 평가 요소를 탐색하여 __'기업 경영 방향 설정 및 마케팅에 도움'__
- 전문적이고 일관된 판단능력 을 기초로 하여 신용위험에 대한 적절한 정보를 투자자에게 제공해 __'정보의 비대칭성 완화'__
- 저성장, 저금리, 새로운 회계기준 도입으로 인한 __'리스크관리 어려움 일부 해소'__



### 팀원 소개

- __강준영__
- __박형권__
  - 전공 : 통계
  - 관심분야 : 머신러닝, 데이터마이닝, 통계
  - 프로그래밍 언어 : _R, Python_
  - 이메일 : parkhk1219@gmail.com
- __허성욱__
  - 전공 : 통계, 금융공학
  - 관심분야 : 머신러닝(딥러닝), 수학, 통계, 금융, 철학
  - 프로그래밍 언어 : _R, Python, SQL_
  - 블로그 : http://analysts.tistory.com/
  - 이메일 : actto8290@gmail.com

### 사용 데이터
- [네이버 증권](http://finance.naver.com/sise/)
  - 재무제표, 주가, ...
- [Catch](http://www.catch.co.kr/)
  - 기업신용등급, 기업정보(사원수, 복리후생, ...) 
- [Microsoft Azure(_Sentiment Analysis_)](https://azure.microsoft.com/ko-kr/services/cognitive-services/text-analytics/)
  - 신용등급 발표일 기준 12개월 전부터 3개월 전까지의 뉴스기사를 크롤링 후 감성분석 실시.
    - ex) 신용등급 발표일이 2017년 12월 10일 경우, 2016년 12월 10일부터 2017년 9월 10일까지의 기사를 크롤링 


### 작업환경

- __Mac OS / Window 10 / Amazon EMR (Master & Worker 2, 총 3대 서버를 빌려 분석에 활용.)__
- Program
  - Python
    - _Selenium_ : 웹사이트를 코드로 제어하는 library, 원하는 웹 마다 driver 필요. (ex. Chrome driver)
    - _BeautifulSoup_ : 웹사이트 크롤링
    - _LexRank(or TextRank)_ : 텍스트 요약해주는 library
    - _Googletrans_ : 구글 번역기
    - _Newspaper_ : url로 해당 뉴스기사 긁어와주는 library
    - _Pandas, Numpy_ : 설명 생략
  - R
    - _RHadoop_ : Amazon에서 빌린 서버에 RHadoop 구축.
    - _randomForest_ : Random Forest 모델링을 위한 library
    - _glm_ : Logisitic Regression을 위한 함수.
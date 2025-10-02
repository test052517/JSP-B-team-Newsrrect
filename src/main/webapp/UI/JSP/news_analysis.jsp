<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>뉴스 신뢰성 분석 시스템</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; color: #333; }
        .header { background: rgba(255, 255, 255, 0.95); backdrop-filter: blur(10px); padding: 1rem 0; box-shadow: 0 2px 20px rgba(0,0,0,0.1); position: sticky; top: 0; z-index: 100; }
        .nav-container { max-width: 1200px; margin: 0 auto; display: flex; justify-content: space-between; align-items: center; padding: 0 2rem; }
        .logo { font-size: 1.5rem; font-weight: bold; color: #667eea; }
        .nav-links a { text-decoration: none; color: #333; margin-left: 2rem; font-weight: 500; transition: color 0.3s; }
        .nav-links a:hover { color: #667eea; }
        .container { max-width: 1000px; margin: 0 auto; padding: 2rem; }
        .hero-section { text-align: center; margin-bottom: 3rem; color: white; }
        .hero-section h1 { font-size: 2.5rem; margin-bottom: 1rem; font-weight: 700; }
        .hero-section p { font-size: 1.1rem; opacity: 0.9; margin-bottom: 0.5rem; }
        .analysis-card { background: rgba(255, 255, 255, 0.95); backdrop-filter: blur(10px); border-radius: 20px; padding: 2.5rem; box-shadow: 0 10px 40px rgba(0,0,0,0.1); margin-bottom: 2rem; }
        .tab-nav { display: flex; border-bottom: 1px solid #e0e0e0; margin-bottom: 1.5rem; }
        .tab-btn { flex: 1; padding: 1rem; cursor: pointer; background: none; border: none; font-size: 1rem; font-weight: 600; color: #666; position: relative; transition: all 0.3s; }
        .tab-btn.active { color: #667eea; }
        .tab-btn.active::after { content: ''; position: absolute; bottom: -1px; left: 0; width: 100%; height: 3px; background-color: #667eea; }
        .tab-content { margin-bottom: 1.5rem; }
        .tab-content.hidden { display: none; }
        .input-group { margin-bottom: 1.5rem; }
        .input-group label { display: block; margin-bottom: 0.5rem; font-weight: 600; color: #333; }
        .input-control { width: 100%; padding: 1rem 1.5rem; border: 2px solid #e0e0e0; border-radius: 12px; font-size: 1rem; transition: all 0.3s; background: white; }
        .input-control:focus { outline: none; border-color: #667eea; box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1); }
        textarea.input-control { resize: vertical; font-family: inherit; }
        .analyze-btn { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none; padding: 1rem 2rem; border-radius: 12px; font-size: 1.1rem; font-weight: 600; cursor: pointer; transition: all 0.3s; display: flex; align-items: center; justify-content: center; gap: 0.5rem; width: 100%; }
        .analyze-btn:hover:not(:disabled) { transform: translateY(-2px); box-shadow: 0 10px 25px rgba(102, 126, 234, 0.3); }
        .analyze-btn:disabled { opacity: 0.6; cursor: not-allowed; }
        .loading-spinner { width: 20px; height: 20px; border: 2px solid rgba(255,255,255,0.3); border-radius: 50%; border-top-color: white; animation: spin 1s ease-in-out infinite; }
        @keyframes spin { to { transform: rotate(360deg); } }
        .error-message { background: #ffebee; color: #c62828; padding: 1rem; border-radius: 8px; margin: 1rem 0; border-left: 4px solid #f44336; display: none; }
        .results-section { margin-top: 2rem; display: none; }
        .summary-section { background: #fff; border-radius: 12px; padding: 2rem; margin-bottom: 2rem; border-left: 4px solid #667eea; }
        .reliability-score { text-align: center; margin-bottom: 2rem; }
        .score-circle { width: 120px; height: 120px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 1rem; font-size: 1.5rem; font-weight: bold; color: white; }
        .score-high { background: linear-gradient(135deg, #4CAF50, #45a049); }
        .score-medium { background: linear-gradient(135deg, #FF9800, #F57C00); }
        .score-low { background: linear-gradient(135deg, #F44336, #D32F2F); }
    </style>
</head>
<body>
    <header class="header">
        <div class="nav-container">
            <div class="logo"><i class="fas fa-search"></i> NewsVerify</div>
            <nav class="nav-links">
                <a href="<%=request.getContextPath()%>/UI/JSP/MainPage.html">홈</a>
                <a href="<%=request.getContextPath()%>/UI/JSP/news_analysis.jsp">분석</a>
                <a href="<%=request.getContextPath()%>/UI/JSP/dashboard.jsp">대시보드</a>
            </nav>
        </div>
    </header>

    <main class="container">
        <section class="hero-section">
            <h1>뉴스 신뢰성 분석 시스템</h1>
            <p>AI 기술을 활용하여 뉴스의 신뢰성을 교차검증하고 객관적인 분석 결과를 제공합니다</p>
        </section>

        <section class="analysis-card">
            <div class="tab-nav">
                <button class="tab-btn active" onclick="switchTab('url', this)"><i class="fas fa-link"></i> URL로 분석</button>
                <button class="tab-btn" onclick="switchTab('text', this)"><i class="fas fa-file-alt"></i> 텍스트로 분석</button>
            </div>

            <form id="analysisForm" onsubmit="return false;">
                <div id="urlTab" class="tab-content">
                    <div class="input-group">
                        <label for="newsUrl">분석할 뉴스 URL을 입력하세요</label>
                        <input type="url" id="newsUrl" name="url" class="input-control" placeholder="https://example.com/news-article">
                    </div>
                </div>

                <div id="textTab" class="tab-content hidden">
                    <div class="input-group">
                        <label for="newsText">분석할 텍스트를 입력하세요</label>
                        <textarea id="newsText" name="text" class="input-control" rows="8" placeholder="분석하고 싶은 뉴스 기사나 글을 여기에 붙여넣으세요..."></textarea>
                    </div>
                </div>

                <button type="button" id="analyzeBtn" class="analyze-btn" onclick="analyzeNews()">
                    <i class="fas fa-search"></i><span>분석 시작</span>
                </button>
            </form>

            <div id="errorMessage" class="error-message"></div>

            <div id="resultsSection" class="results-section">
                <h2>분석 결과</h2>
                <div class="summary-section">
                    <h3><i class="fas fa-file-alt"></i> 원본 글 요약</h3>
                    <div id="originalSummary"></div>
                </div>
                <div class="reliability-score">
                    <div id="scoreCircle" class="score-circle"><span id="scoreValue">0%</span></div>
                    <h3>신뢰성 점수</h3>
                </div>
            </div>
        </section>
    </main>

    <script>
        var activeTab = 'url';
        var postId = null;

        function switchTab(tab, element) {
            activeTab = tab;
            document.querySelectorAll('.tab-btn').forEach(function(btn) { btn.classList.remove('active'); });
            element.classList.add('active');
            document.getElementById('urlTab').classList.toggle('hidden', tab !== 'url');
            document.getElementById('textTab').classList.toggle('hidden', tab !== 'text');
            hideError();
            hideResults();
        }
        
        function analyzeNews() {
            var url = document.getElementById('newsUrl').value.trim();
            var text = document.getElementById('newsText').value.trim();
            
            if (activeTab === 'url' && url === '') { 
                showError('분석할 URL을 입력해주세요.'); 
                return; 
            }
            if (activeTab === 'text' && text === '') { 
                showError('분석할 텍스트를 입력해주세요.'); 
                return; 
            }

            var dataToSend = { 
                url: activeTab === 'url' ? url : '', 
                text: activeTab === 'text' ? text : '' 
            };
            
            setLoadingState(true);
            hideError();
            hideResults();

            fetch('http://113.198.238.113:5000/analyze', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(dataToSend)
            }).then(function(response) { 
                return response.json(); 
            }).then(function(result) {
                if (result.success) { 
                    displayResults(result); 
                } else { 
                    showError(result.error || '분석 중 오류가 발생했습니다.'); 
                }
            }).catch(function(error) {
                console.error('분석 요청 오류:', error);
                showError('백엔드 서버에 연결할 수 없습니다.');
            }).finally(function() { 
                setLoadingState(false); 
            });
        }
        
        function setLoadingState(isLoading) {
            var analyzeBtn = document.getElementById('analyzeBtn');
            if (isLoading) {
                analyzeBtn.disabled = true;
                analyzeBtn.innerHTML = '<div class="loading-spinner"></div><span>분석 중...</span>';
            } else {
                analyzeBtn.disabled = false;
                analyzeBtn.innerHTML = '<i class="fas fa-search"></i><span>분석 시작</span>';
            }
        }

        function displayResults(result) {
            document.getElementById('originalSummary').textContent = result.original_summary || result.summary || '요약을 생성할 수 없습니다.';

            var scoreValue = document.getElementById('scoreValue');
            var scoreCircle = document.getElementById('scoreCircle');
            scoreValue.textContent = (result.reliability_score || 0).toFixed(1) + '%';
            
            scoreCircle.className = 'score-circle';
            if (result.reliability_score >= 80) { 
                scoreCircle.classList.add('score-high'); 
            } else if (result.reliability_score >= 60) { 
                scoreCircle.classList.add('score-medium'); 
            } else { 
                scoreCircle.classList.add('score-low'); 
            }

            document.getElementById('resultsSection').style.display = 'block';
            
            if (postId) {
                saveAnalysisToDatabase(result);
            }
        }

        function saveAnalysisToDatabase(result) {
            var originalUrl;
            if (activeTab === 'url') {
                originalUrl = document.getElementById('newsUrl').value.trim();
            } else {
                originalUrl = 'text:postId:' + postId;
            }
            
            fetch('<%=request.getContextPath()%>/UI/JSP/saveAnalysisResult.jsp', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                body: JSON.stringify({
                    postId: postId,
                    originalUrl: originalUrl,
                    keywords: result.keywords ? result.keywords.join(',') : '',
                    relatedArticlesCount: result.articles_analyzed || 0,
                    summary: result.original_summary || result.summary || '',
                    reliabilityScore: result.reliability_score || 0,
                    analysisDetails: result.verification_details || '',
                    processingTime: parseInt(result.processing_time) || 0
                })
            }).then(function(response) { 
                return response.json(); 
            }).then(function(data) {
                if (data.success) {
                    console.log('DB 저장 성공:', data.analysisId);
                }
            }).catch(function(error) {
                console.error('DB 저장 실패:', error);
            });
        }

        function showError(message) {
            var errorDiv = document.getElementById('errorMessage');
            errorDiv.innerHTML = '<i class="fas fa-exclamation-triangle"></i> ' + escapeHtml(message);
            errorDiv.style.display = 'block';
        }

        function hideError() { 
            document.getElementById('errorMessage').style.display = 'none'; 
        }
        
        function hideResults() { 
            document.getElementById('resultsSection').style.display = 'none'; 
        }
        
        function escapeHtml(text) { 
            var div = document.createElement('div'); 
            div.textContent = text || ''; 
            return div.innerHTML; 
        }

        // ★★★ SessionStorage 사용 (URL 파라미터 대신) ★★★
        window.addEventListener('load', function() {
            try {
                // SessionStorage에서 데이터 읽기
                var transferData = sessionStorage.getItem('newsAnalysisData');
                if (transferData) {
                    var data = JSON.parse(transferData);
                    console.log('전달받은 데이터:', data);
                    
                    // postId 저장
                    postId = data.postId;
                    
                    // 데이터 설정
                    if (data.type === 'url') {
                        activeTab = 'url';
                        document.getElementById('urlTab').classList.remove('hidden');
                        document.getElementById('textTab').classList.add('hidden');
                        document.querySelectorAll('.tab-btn')[0].classList.add('active');
                        document.querySelectorAll('.tab-btn')[1].classList.remove('active');
                        document.getElementById('newsUrl').value = data.content;
                    } else if (data.type === 'text') {
                        activeTab = 'text';
                        document.getElementById('urlTab').classList.add('hidden');
                        document.getElementById('textTab').classList.remove('hidden');
                        document.querySelectorAll('.tab-btn')[0].classList.remove('active');
                        document.querySelectorAll('.tab-btn')[1].classList.add('active');
                        document.getElementById('newsText').value = data.content;
                    }
                    
                    // SessionStorage 데이터 삭제 (일회성)
                    sessionStorage.removeItem('newsAnalysisData');
                    
                    // 자동 분석 시작
                    setTimeout(function() {
                        analyzeNews();
                    }, 500);
                }
            } catch (error) { 
                console.error('데이터 로드 오류:', error); 
            }
        });
    </script>
</body>
</html>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>대시보드 - NewsVerify</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: #333;
        }

        .header {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            padding: 1rem 0;
            box-shadow: 0 2px 20px rgba(0,0,0,0.1);
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .nav-container {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0 2rem;
        }

        .logo {
            font-size: 1.5rem;
            font-weight: bold;
            color: #667eea;
        }

        .nav-links a {
            text-decoration: none;
            color: #333;
            margin-left: 2rem;
            font-weight: 500;
            transition: color 0.3s;
        }

        .nav-links a:hover {
            color: #667eea;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem;
        }

        .page-title {
            text-align: center;
            margin-bottom: 2rem;
            color: white;
        }

        .page-title h1 {
            font-size: 2.5rem;
            margin-bottom: 0.5rem;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 2rem;
            text-align: center;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            transition: transform 0.3s;
        }

        .stat-card:hover {
            transform: translateY(-5px);
        }

        .stat-icon {
            font-size: 2.5rem;
            margin-bottom: 1rem;
            color: #667eea;
        }

        .stat-value {
            font-size: 2rem;
            font-weight: bold;
            color: #333;
            margin-bottom: 0.5rem;
        }

        .stat-label {
            color: #666;
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .charts-section {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 2rem;
            margin-bottom: 2rem;
        }

        .chart-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 2rem;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
        }

        .chart-title {
            font-size: 1.3rem;
            font-weight: 600;
            margin-bottom: 1.5rem;
            color: #333;
            text-align: center;
        }

        .chart-container {
            position: relative;
            height: 300px;
        }

        .recent-analyses {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 2rem;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
        }

        .section-title {
            font-size: 1.5rem;
            font-weight: 600;
            margin-bottom: 1.5rem;
            color: #333;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .refresh-btn {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            padding: 0.8rem 1.5rem;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .refresh-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
        }

        .analysis-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1.5rem;
            margin-bottom: 1rem;
            background: #f8f9fa;
            border-radius: 10px;
            border-left: 4px solid #667eea;
            transition: all 0.3s;
        }

        .analysis-item:hover {
            transform: translateX(5px);
            box-shadow: 0 3px 15px rgba(0,0,0,0.1);
        }

        .analysis-info h4 {
            margin-bottom: 0.5rem;
            color: #333;
        }

        .analysis-meta {
            font-size: 0.9rem;
            color: #666;
        }

        .reliability-badge {
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.9rem;
            color: white;
        }

        .reliability-high { background: linear-gradient(135deg, #4CAF50, #45a049); }
        .reliability-medium { background: linear-gradient(135deg, #FF9800, #F57C00); }
        .reliability-low { background: linear-gradient(135deg, #F44336, #D32F2F); }

        .loading {
            text-align: center;
            padding: 2rem;
            color: #666;
        }

        .loading-spinner {
            width: 40px;
            height: 40px;
            border: 4px solid #f3f3f3;
            border-top: 4px solid #667eea;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin: 0 auto 1rem;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        @media (max-width: 768px) {
            .charts-section {
                grid-template-columns: 1fr;
            }
            .analysis-item {
                flex-direction: column;
                gap: 1rem;
            }
        }
    </style>
</head>
<body>
    <header class="header">
        <div class="nav-container">
            <div class="logo">
                <i class="fas fa-search"></i> NewsVerify
            </div>
            <nav class="nav-links">
    			<a href="<%=request.getContextPath()%>/UI/JSP/MainPage.html">홈</a>
    			<a href="<%=request.getContextPath()%>/UI/JSP/news_analysis.jsp">분석</a>
    			<a href="<%=request.getContextPath()%>/UI/JSP/dashboard.jsp">대시보드</a>
			</nav>
        </div>
    </header>

    <main class="container">
        <section class="page-title">
            <h1><i class="fas fa-chart-line"></i> 분석 대시보드</h1>
            <p>뉴스 분석 통계와 최근 결과를 확인하세요</p>
        </section>

        <section class="stats-grid" id="statsGrid">
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-newspaper"></i>
                </div>
                <div class="stat-value" id="totalAnalyses">-</div>
                <div class="stat-label">이 분석 건수</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-percentage"></i>
                </div>
                <div class="stat-value" id="averageReliability">-</div>
                <div class="stat-label">평균 신뢰도</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-shield-alt"></i>
                </div>
                <div class="stat-value" id="highReliabilityCount">-</div>
                <div class="stat-label">고신뢰도 뉴스</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div class="stat-value" id="factCheckSuccess">-</div>
                <div class="stat-label">팩트체킹 완료</div>
            </div>
        </section>

        <section class="charts-section">
            <div class="chart-card">
                <h3 class="chart-title">신뢰도 분포</h3>
                <div class="chart-container">
                    <canvas id="reliabilityChart"></canvas>
                </div>
            </div>
            
            <div class="chart-card">
                <h3 class="chart-title">일별 분석 추이</h3>
                <div class="chart-container">
                    <canvas id="analysisChart"></canvas>
                </div>
            </div>
        </section>

        <section class="recent-analyses">
            <div class="section-title">
                <div>
                    <i class="fas fa-history"></i>
                    최근 분석 결과
                </div>
                <button class="refresh-btn" onclick="loadDashboardData()">
                    <i class="fas fa-refresh"></i>
                    새로고침
                </button>
            </div>
            <div id="recentAnalyses">
                <div class="loading">
                    <div class="loading-spinner"></div>
                    <p>데이터를 불러오는 중...</p>
                </div>
            </div>
        </section>
    </main>

    <script>
        let charts = {};

        document.addEventListener('DOMContentLoaded', function() {
            loadDashboardData();
        });

        async function loadDashboardData() {
            const loadingDiv = document.getElementById('recentAnalyses');
            loadingDiv.innerHTML = `
                <div class="loading">
                    <div class="loading-spinner"></div>
                    <p>데이터를 불러오는 중...</p>
                </div>`;
            
            try {
                const response = await fetch('http://113.198.238.113:5000/api/stats');
                const data = await response.json();

                if (data.success) {
                    updateStats(data.stats);
                    updateCharts(data.stats);
                    updateRecentAnalyses(data.stats.recent_analyses);
                } else {
                    showError('통계 데이터를 불러올 수 없습니다: ' + data.error);
                }
            } catch (error) {
                console.error('데이터 로드 실패:', error);
                showError('백엔드 서버에 연결할 수 없습니다. 서버가 실행 중인지 확인해주세요.');
            }
        }

        function updateStats(stats) {
            document.getElementById('totalAnalyses').textContent = stats.total_analyses || 0;
            document.getElementById('averageReliability').textContent = (stats.average_reliability || 0) + '%';
            document.getElementById('highReliabilityCount').textContent = stats.reliability_distribution?.high || 0;
            const factCheckSuccess = (stats.reliability_distribution?.high || 0) + 
                                   (stats.reliability_distribution?.medium || 0);
            document.getElementById('factCheckSuccess').textContent = factCheckSuccess;
        }

        function updateCharts(stats) {
            createReliabilityChart(stats.reliability_distribution || {});
            createAnalysisChart(stats.recent_analyses || []);
        }

        function createReliabilityChart(distribution) {
            const ctx = document.getElementById('reliabilityChart').getContext('2d');
            if (charts.reliability) {
                charts.reliability.destroy();
            }
            charts.reliability = new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: ['고신뢰도 (80% 이상)', '중신뢰도 (60-80%)', '저신뢰도 (60% 미만)'],
                    datasets: [{
                        data: [
                            distribution.high || 0, 
                            distribution.medium || 0, 
                            distribution.low || 0
                        ],
                        backgroundColor: ['#4CAF50', '#FF9800', '#F44336'],
                        borderWidth: 0,
                        hoverOffset: 4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: { padding: 20, usePointStyle: true, font: { size: 12 } }
                        }
                    }
                }
            });
        }

        function createAnalysisChart(recentAnalyses) {
            const ctx = document.getElementById('analysisChart').getContext('2d');
            if (charts.analysis) {
                charts.analysis.destroy();
            }

            const last7Days = generateLast7DaysData(recentAnalyses);
            charts.analysis = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: last7Days.labels,
                    datasets: [{
                        label: '일별 분석 건수',
                        data: last7Days.data,
                        borderColor: '#667eea',
                        backgroundColor: 'rgba(102, 126, 234, 0.1)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.4,
                        pointBackgroundColor: '#667eea',
                        pointBorderColor: '#fff',
                        pointBorderWidth: 2,
                        pointRadius: 6,
                        pointHoverRadius: 8
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                        y: { beginAtZero: true, grid: { color: 'rgba(0,0,0,0.1)' }, ticks: { stepSize: 1 } },
                        x: { grid: { color: 'rgba(0,0,0,0.1)' } }
                    }
                }
            });
        }

        function generateLast7DaysData(analyses) {
            const analysisCounts = {};
            const today = new Date();

            for (let i = 6; i >= 0; i--) {
                const date = new Date(today);
                date.setDate(date.getDate() - i);
                const key = date.toISOString().split('T')[0];
                analysisCounts[key] = 0;
            }

            if(analyses) {
                analyses.forEach(analysis => {
                    const key = new Date(analysis.created_at).toISOString().split('T')[0];
                    if (key in analysisCounts) {
                        analysisCounts[key]++;
                    }
                });
            }
            
            const labels = Object.keys(analysisCounts).map(key => {
                const date = new Date(key);
                return date.toLocaleDateString('ko-KR', { month: 'short', day: 'numeric' });
            });
            const data = Object.values(analysisCounts);

            return { labels, data };
        }

        function updateRecentAnalyses(analyses) {
            const container = document.getElementById('recentAnalyses');
            if (!analyses || analyses.length === 0) {
                container.innerHTML = '<p style="text-align: center; color: #666;">최근 분석 결과가 없습니다.</p>';
                return;
            }

            let htmlContent = '';
            analyses.forEach(function(analysis) {
                const score = analysis.reliability_score || 0;
                let badgeClass = 'reliability-low';
                let badgeText = '저신뢰도';
                
                if (score >= 80) {
                    badgeClass = 'reliability-high';
                    badgeText = '고신뢰도';
                } else if (score >= 60) {
                    badgeClass = 'reliability-medium';
                    badgeText = '중신뢰도';
                }

                const analysisDate = new Date(analysis.created_at).toLocaleString('ko-KR');

                htmlContent += 
                    '<div class="analysis-item">' +
                        '<div class="analysis-info">' +
                            '<h4>키워드: ' + escapeHtml(analysis.keywords || '정보 없음') + '</h4>' +
                            '<div class="analysis-meta">' +
                                '<span><i class="fas fa-newspaper"></i> ' + (analysis.articles_count || 0) + '건 분석</span> | ' +
                                '<span><i class="fas fa-clock"></i> ' + analysisDate + '</span>' +
                            '</div>' +
                        '</div>' +
                        '<div class="reliability-badge ' + badgeClass + '">' +
                            score.toFixed(1) + '% ' + badgeText +
                        '</div>' +
                    '</div>';
            });
            container.innerHTML = htmlContent;
        }

        function showError(message) {
            const container = document.getElementById('recentAnalyses');
            container.innerHTML = 
                '<div style="text-align: center; padding: 2rem; color: #f44336;">' +
                    '<i class="fas fa-exclamation-triangle" style="font-size: 2rem; margin-bottom: 1rem;"></i>' +
                    '<p>' + escapeHtml(message) + '</p>' +
                '</div>';
        }

        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text || '';
            return div.innerHTML;
        }

        window.addEventListener('resize', () => {
            Object.values(charts).forEach(chart => {
                if (chart) chart.resize();
            });
        });
    </script>
</body>
</html>
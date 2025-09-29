package mgr;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.*;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

/**
 * 개선된 한국어 키워드 추출 Manager (도메인 추출 제외)
 */
public class KeywordExtractorMgr {
    
    private static final String USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36";
    private static final int TIMEOUT = 15000;
    
    // 한국어 불용어 (포괄적)
    private static final Set<String> STOP_WORDS = new HashSet<>(Arrays.asList(
        // 조사
        "것이", "그것", "이것", "저것", "여기", "거기", "저기", "어디", "언제", "무엇", "누구",
        "에서", "에게", "에는", "에도", "에만", "으로", "로서", "까지", "부터", "처럼", "같이",
        "하지만", "그러나", "그런데", "따라서", "그래서", "또한", "또는", "그리고", "하지만",
        // 동사/형용사 어미
        "하는", "되는", "있는", "없는", "같은", "다른", "많은", "적은", "새로운", "오래된",
        "좋다", "나쁘다", "크다", "작다", "높다", "낮다", "빠르다", "느리다", "쉽다", "어렵다",
        // 기능어
        "때문", "경우", "때문에", "통해", "위해", "대해", "관련", "의해", "대한", "위한",
        "사람", "때문", "정도", "생각", "말씀", "이야기", "방법", "문제", "상황", "경우",
        // 일반적인 단어
        "우리", "저희", "그들", "자신", "서로", "모든", "각각", "전체", "일부", "대부분",
        "지난", "다음", "이번", "올해", "내년", "작년", "최근", "현재", "미래", "과거",
        "이후", "이전", "동안", "사이", "중간", "끝에", "처음", "마지막", "항상", "절대",
        // 추가 불용어
        "이러한", "그러한", "이런", "그런", "저런", "어떤", "어느", "무슨", "어떠한",
        "라고", "말한", "했다", "한다", "이다", "있다", "없다", "된다", "되다", "하다"
    ));
    
    // 중요한 명사 접미사들
    private static final Set<String> IMPORTANT_SUFFIXES = new HashSet<>(Arrays.asList(
        "사업", "산업", "기업", "회사", "정부", "대통령", "장관", "시장", "구청장",
        "협회", "조합", "단체", "기관", "위원회", "연구소", "대학교", "학교",
        "병원", "센터", "공단", "공사", "재단", "법인", "그룹", "계획", "정책",
        "시스템", "서비스", "플랫폼", "프로그램", "프로젝트", "사건", "사고"
    ));
    
    /**
     * URL에서 고도화된 키워드 추출 및 요약
     */
    public Map<String, Object> extractKeywordsAndSummary(String url) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            System.out.println("키워드 추출 및 요약 시작: " + url);
            
            // 1. 웹페이지 내용 추출
            String content = extractContentFromUrl(url);
            if (content == null || content.trim().isEmpty()) {
                System.err.println("콘텐츠 추출 실패, 기본 결과 반환");
                result.put("keywords", getDefaultKeywords());
                result.put("summary", "콘텐츠를 추출할 수 없어 요약을 생성하지 못했습니다.");
                return result;
            }
            
            // 2. 텍스트 전처리 및 정제
            String cleanContent = preprocessText(content);
            
            // 3. 키워드 추출
            List<String> keywords = extractKeywordsFromContent(cleanContent);
            
            // 4. 요약 생성
            String summary = generateSummary(content, keywords);
            
            result.put("keywords", keywords);
            result.put("summary", summary);
            result.put("contentLength", content.length());
            
            System.out.println("키워드 추출 및 요약 완료");
            return result;
            
        } catch (Exception e) {
            System.err.println("키워드 추출 및 요약 오류: " + e.getMessage());
            e.printStackTrace();
            result.put("keywords", getDefaultKeywords());
            result.put("summary", "분석 중 오류가 발생했습니다.");
            return result;
        }
    }
    
    /**
     * 기존 키워드 추출 메소드 (하위 호환성)
     */
    public List<String> extractKeywords(String url) {
        Map<String, Object> result = extractKeywordsAndSummary(url);
        return (List<String>) result.get("keywords");
    }
    
    /**
     * 콘텐츠에서 키워드 추출
     */
    private List<String> extractKeywordsFromContent(String content) {
        Map<String, Integer> keywordScores = new HashMap<>();
        
        // 1단계: 고빈도 명사 추출
        extractFrequentNouns(content, keywordScores);
        
        // 2단계: 복합명사 및 전문용어 추출
        extractCompoundNouns(content, keywordScores);
        
        // 3단계: 고유명사 추출 (인명, 지명, 기관명 등)
        extractProperNouns(content, keywordScores);
        
        // 4단계: 점수 기반 정렬 및 선택
        List<String> keywords = selectTopKeywords(keywordScores, 10);
        
        // 5단계: 후처리 및 정제
        return postProcessKeywords(keywords);
    }
    
    /**
     * 뉴스 기사 요약 생성
     */
    private String generateSummary(String content, List<String> keywords) {
        try {
            // 1. 문장 단위로 분리
            List<String> sentences = splitIntoSentences(content);
            if (sentences.isEmpty()) {
                return "요약할 수 있는 문장을 찾지 못했습니다.";
            }
            
            // 2. 각 문장에 점수 부여
            List<SentenceScore> scoredSentences = scoreSentences(sentences, keywords);
            
            // 3. 상위 점수 문장들로 요약 생성
            return generateFinalSummary(scoredSentences, keywords);
            
        } catch (Exception e) {
            System.err.println("요약 생성 오류: " + e.getMessage());
            return "요약 생성 중 오류가 발생했습니다.";
        }
    }
    
    /**
     * 텍스트를 문장 단위로 분리
     */
    private List<String> splitIntoSentences(String content) {
        List<String> sentences = new ArrayList<>();
        
        // 한국어 문장 끝 패턴으로 분리
        String[] sentenceEnders = content.split("[.!?。]");
        
        for (String sentence : sentenceEnders) {
            String cleaned = sentence.trim();
            // 의미있는 길이의 문장만 포함 (10자 이상)
            if (cleaned.length() >= 10 && cleaned.length() <= 200) {
                sentences.add(cleaned);
            }
        }
        
        return sentences;
    }
    
    /**
     * 문장별 점수 계산
     */
    private List<SentenceScore> scoreSentences(List<String> sentences, List<String> keywords) {
        List<SentenceScore> scoredSentences = new ArrayList<>();
        
        for (int i = 0; i < sentences.size(); i++) {
            String sentence = sentences.get(i);
            double score = calculateSentenceScore(sentence, keywords, i, sentences.size());
            scoredSentences.add(new SentenceScore(sentence, score, i));
        }
        
        // 점수 순으로 정렬
        scoredSentences.sort((a, b) -> Double.compare(b.score, a.score));
        
        return scoredSentences;
    }
    
    /**
     * 개별 문장 점수 계산
     */
    private double calculateSentenceScore(String sentence, List<String> keywords, int position, int totalSentences) {
        double score = 0.0;
        
        // 1. 키워드 포함 점수 (가장 중요)
        for (String keyword : keywords) {
            if (sentence.contains(keyword)) {
                score += 10.0;
            }
        }
        
        // 2. 위치 점수 (첫 문장과 마지막 문장 가중치)
        if (position == 0) {
            score += 5.0; // 첫 문장
        } else if (position == totalSentences - 1) {
            score += 3.0; // 마지막 문장
        } else if (position < totalSentences * 0.3) {
            score += 2.0; // 앞쪽 문장들
        }
        
        // 3. 문장 길이 점수 (너무 짧거나 너무 긴 문장 페널티)
        int length = sentence.length();
        if (length >= 20 && length <= 100) {
            score += 2.0; // 적당한 길이
        } else if (length > 100) {
            score -= 1.0; // 너무 긴 문장 페널티
        }
        
        // 4. 중요 단어 포함 점수
        String[] importantWords = {"발표", "결정", "계획", "정책", "방안", "대책", "결과", "성과", "문제", "해결"};
        for (String word : importantWords) {
            if (sentence.contains(word)) {
                score += 1.0;
            }
        }
        
        // 5. 숫자나 구체적 데이터 포함 점수
        if (sentence.matches(".*[0-9].*")) {
            score += 1.5;
        }
        
        return score;
    }
    
    /**
     * 최종 요약문 생성
     */
    private String generateFinalSummary(List<SentenceScore> scoredSentences, List<String> keywords) {
        StringBuilder summary = new StringBuilder();
        
        // 상위 3-4개 문장 선택
        int summaryLength = Math.min(4, scoredSentences.size());
        List<SentenceScore> selectedSentences = new ArrayList<>();
        
        for (int i = 0; i < summaryLength && i < scoredSentences.size(); i++) {
            SentenceScore sentenceScore = scoredSentences.get(i);
            if (sentenceScore.score > 5.0) { // 최소 점수 기준
                selectedSentences.add(sentenceScore);
            }
        }
        
        // 원래 순서대로 정렬
        selectedSentences.sort((a, b) -> Integer.compare(a.position, b.position));
        
        // 요약문 구성
        summary.append("주요 키워드: ").append(String.join(", ", keywords.subList(0, Math.min(5, keywords.size())))).append("\n\n");
        
        summary.append("요약:\n");
        for (SentenceScore sentence : selectedSentences) {
            summary.append("• ").append(sentence.sentence).append(".\n");
        }
        
        // 추가 정보
        if (selectedSentences.size() > 0) {
            summary.append("\n분석 결과: ");
            summary.append("총 ").append(selectedSentences.size()).append("개의 핵심 문장으로 요약되었습니다.");
        }
        
        return summary.toString();
    }
    
    /**
     * 문장 점수를 저장하는 내부 클래스
     */
    private static class SentenceScore {
        String sentence;
        double score;
        int position;
        
        SentenceScore(String sentence, double score, int position) {
            this.sentence = sentence;
            this.score = score;
            this.position = position;
        }
    }
    
    /**
     * 1단계: 고빈도 명사 추출
     */
    private void extractFrequentNouns(String content, Map<String, Integer> scores) {
        // 한글 명사 패턴 (2-8글자)
        Pattern nounPattern = Pattern.compile("[가-힣]{2,8}");
        Matcher matcher = nounPattern.matcher(content);
        
        while (matcher.find()) {
            String word = matcher.group();
            
            // 불용어 및 단순 반복 문자 필터링
            if (!STOP_WORDS.contains(word) && !isRepeatingChar(word) && isValidNoun(word)) {
                scores.merge(word, getBaseScore(word), Integer::sum);
            }
        }
    }
    
    /**
     * 2단계: 복합명사 및 전문용어 추출
     */
    private void extractCompoundNouns(String content, Map<String, Integer> scores) {
        // 복합명사 패턴들
        String[] compoundPatterns = {
            "[가-힣]{2,6}(사업|산업|기업|회사|정부|정책|시스템|프로그램|프로젝트)",
            "[가-힣]{2,6}(위원회|연구소|대학교|센터|재단|협회|조합)",
            "[가-힣]{2,6}(계획|방안|대책|전략|정책|개혁|혁신)",
            "([가-힣]{2,4}\\s*[가-힣]{2,4}\\s*[가-힣]{2,4})" // 3단어 복합명사
        };
        
        for (String patternStr : compoundPatterns) {
            Pattern pattern = Pattern.compile(patternStr);
            Matcher matcher = pattern.matcher(content);
            
            while (matcher.find()) {
                String compound = matcher.group().trim();
                if (compound.length() >= 4 && compound.length() <= 20) {
                    scores.merge(compound, 5, Integer::sum); // 복합명사는 높은 점수
                }
            }
        }
    }
    
    /**
     * 3단계: 고유명사 추출 (인명, 지명, 기관명)
     */
    private void extractProperNouns(String content, Map<String, Integer> scores) {
        // 인명 패턴 (성+이름)
        Pattern namePattern = Pattern.compile("([김이박최정강조윤장임])[가-힣]{1,3}(씨|의원|장관|대통령|시장|구청장|교수|박사|대표|회장)?");
        Matcher nameMatcher = namePattern.matcher(content);
        
        while (nameMatcher.find()) {
            String name = nameMatcher.group().replaceAll("(씨|의원|장관|대통령|시장|구청장|교수|박사|대표|회장)", "");
            if (name.length() >= 2 && name.length() <= 4) {
                scores.merge(name, 3, Integer::sum);
            }
        }
        
        // 지명 패턴
        Pattern locationPattern = Pattern.compile("([가-힣]{1,4}(시|군|구|도|동|면|리|로|길|대학교|공항|역|항))");
        Matcher locationMatcher = locationPattern.matcher(content);
        
        while (locationMatcher.find()) {
            String location = locationMatcher.group();
            if (location.length() >= 3 && location.length() <= 8) {
                scores.merge(location, 3, Integer::sum);
            }
        }
        
        // 기관명 패턴
        Pattern orgPattern = Pattern.compile("([가-힣]{2,8}(청|부|처|원|공사|공단|협회|재단|회사|그룹|은행|증권|보험))");
        Matcher orgMatcher = orgPattern.matcher(content);
        
        while (orgMatcher.find()) {
            String org = orgMatcher.group();
            if (org.length() >= 3 && org.length() <= 12) {
                scores.merge(org, 4, Integer::sum);
            }
        }
    }
    
    /**
     * 점수 기반 상위 키워드 선택
     */
    private List<String> selectTopKeywords(Map<String, Integer> scores, int maxCount) {
        return scores.entrySet().stream()
                .sorted((e1, e2) -> e2.getValue().compareTo(e1.getValue()))
                .filter(entry -> entry.getValue() >= 2) // 최소 2점 이상
                .limit(maxCount)
                .map(Map.Entry::getKey)
                .collect(ArrayList::new, (list, item) -> list.add(item), (list1, list2) -> list1.addAll(list2));
    }
    
    /**
     * 키워드 후처리 및 정제
     */
    private List<String> postProcessKeywords(List<String> keywords) {
        List<String> processedKeywords = new ArrayList<>();
        Set<String> seen = new HashSet<>();
        
        for (String keyword : keywords) {
            String processed = keyword.trim();
            
            // 중복 제거 (유사한 키워드 통합)
            if (!isDuplicateKeyword(processed, seen)) {
                processedKeywords.add(processed);
                seen.add(processed);
            }
            
            if (processedKeywords.size() >= 8) break;
        }
        
        return processedKeywords;
    }
    
    /**
     * 유사 키워드 중복 검사
     */
    private boolean isDuplicateKeyword(String keyword, Set<String> existing) {
        for (String existing_kw : existing) {
            if (keyword.contains(existing_kw) || existing_kw.contains(keyword)) {
                return true;
            }
            // 편집 거리가 매우 가까운 경우도 중복으로 간주
            if (calculateSimilarity(keyword, existing_kw) > 0.8) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * 문자열 유사도 계산 (간단한 버전)
     */
    private double calculateSimilarity(String s1, String s2) {
        if (s1.equals(s2)) return 1.0;
        if (s1.length() == 0 || s2.length() == 0) return 0.0;
        
        int maxLen = Math.max(s1.length(), s2.length());
        int commonChars = 0;
        
        for (int i = 0; i < Math.min(s1.length(), s2.length()); i++) {
            if (s1.charAt(i) == s2.charAt(i)) {
                commonChars++;
            }
        }
        
        return (double) commonChars / maxLen;
    }
    
    /**
     * 기본 점수 계산
     */
    private int getBaseScore(String word) {
        int score = 1;
        
        // 길이에 따른 가중치
        if (word.length() >= 4) score += 1;
        if (word.length() >= 6) score += 1;
        
        // 중요 접미사가 있으면 가중치
        for (String suffix : IMPORTANT_SUFFIXES) {
            if (word.endsWith(suffix)) {
                score += 2;
                break;
            }
        }
        
        return score;
    }
    
    /**
     * 유효한 명사인지 검사
     */
    private boolean isValidNoun(String word) {
        // 숫자만 있는 경우 제외
        if (word.matches(".*\\d.*")) return false;
        
        // 의미없는 반복 패턴 제외
        if (word.matches("(.)\\1{2,}")) return false;
        
        // 특정 패턴 제외
        if (word.matches("(하하|ㅎㅎ|헤헤|히히)")) return false;
        
        return true;
    }
    
    /**
     * 반복 문자 검사
     */
    private boolean isRepeatingChar(String word) {
        if (word.length() <= 2) return false;
        
        char firstChar = word.charAt(0);
        for (int i = 1; i < word.length(); i++) {
            if (word.charAt(i) != firstChar) {
                return false;
            }
        }
        return true;
    }
    
    /**
     * URL에서 웹페이지 내용 추출
     */
    private String extractContentFromUrl(String urlString) {
        try {
            URL url = new URL(urlString);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setRequestProperty("User-Agent", USER_AGENT);
            connection.setConnectTimeout(TIMEOUT);
            connection.setReadTimeout(TIMEOUT);
            
            int responseCode = connection.getResponseCode();
            if (responseCode != HttpURLConnection.HTTP_OK) {
                System.err.println("HTTP 오류 코드: " + responseCode);
                return null;
            }
            
            StringBuilder html = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(connection.getInputStream(), "UTF-8"))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    html.append(line).append("\n");
                }
            }
            
            Document doc = Jsoup.parse(html.toString());
            String title = extractTitle(doc);
            String content = extractMainContent(doc);
            
            return title + " " + content;
            
        } catch (Exception e) {
            System.err.println("웹페이지 추출 오류: " + e.getMessage());
            return null;
        }
    }
    
    /**
     * HTML에서 제목 추출
     */
    private String extractTitle(Document doc) {
        String[] titleSelectors = {
            "h1.headline", "h1.title", ".article-title h1", 
            ".news-title", "h1", "title"
        };
        
        for (String selector : titleSelectors) {
            Elements elements = doc.select(selector);
            if (!elements.isEmpty()) {
                String title = elements.first().text();
                if (title.length() > 10) {
                    return cleanText(title);
                }
            }
        }
        
        return "";
    }
    
    /**
     * HTML에서 본문 내용 추출
     */
    private String extractMainContent(Document doc) {
        doc.select("script, style, nav, header, footer, aside, advertisement").remove();
        
        String[] contentSelectors = {
            "article", ".article-body", ".article-content", ".news-content",
            ".content", "#articleBodyContents", ".article_body", 
            ".view-content", ".post-content"
        };
        
        for (String selector : contentSelectors) {
            Elements elements = doc.select(selector);
            if (!elements.isEmpty()) {
                String content = elements.first().text();
                if (content.length() > 100) {
                    return cleanText(content);
                }
            }
        }
        
        Elements paragraphs = doc.select("p");
        StringBuilder content = new StringBuilder();
        for (Element p : paragraphs) {
            String text = p.text();
            if (text.length() > 20) {
                content.append(text).append(" ");
            }
        }
        
        return cleanText(content.toString());
    }
    
    /**
     * 텍스트 정리
     */
    private String cleanText(String text) {
        if (text == null) return "";
        
        text = text.replaceAll("&nbsp;", " ")
                  .replaceAll("&lt;", "<")
                  .replaceAll("&gt;", ">")
                  .replaceAll("&amp;", "&")
                  .replaceAll("&quot;", "\"");
        
        text = text.replaceAll("\\s+", " ");
        
        return text.trim();
    }
    
    /**
     * 텍스트 전처리
     */
    private String preprocessText(String text) {
        if (text == null) return "";
        
        // 불필요한 패턴 제거
        text = text.replaceAll("\\b\\w*\\d+\\w*\\b", " ");  // 숫자 포함 단어
        text = text.replaceAll("\\b[a-zA-Z]+\\b", " ");     // 영어 단어
        text = text.replaceAll("[^가-힣\\s]", " ");         // 한글과 공백만 유지
        text = text.replaceAll("\\s+", " ");               // 연속 공백 정리
        
        return text.trim();
    }
    
    /**
     * 기본 키워드 반환
     */
    private List<String> getDefaultKeywords() {
        return Arrays.asList("뉴스", "분석", "정보", "사회", "경제", "정치", "기술", "문화");
    }
}
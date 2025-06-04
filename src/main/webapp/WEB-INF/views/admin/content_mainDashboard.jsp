<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>



<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-6">
    <!-- 오늘 방문자 수 -->
    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center justify-between mb-4">
            <h3 class="text-gray-500 text-sm font-medium">오늘 방문자 수</h3>
            <div class="w-10 h-10 rounded-full bg-indigo-100 flex items-center justify-center text-indigo-600">
                <i class="ri-ancient-gate-fill ri-lg"></i>
            </div>
        </div>
        <span class="text-3xl font-bold text-gray-800">${visitorsToday}</span>
        <p class="text-xs text-gray-500 mt-1">오늘 로그인 사용자</p>
    </div>
    <!-- 총 회원수 -->
    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center justify-between mb-4">
            <h3 class="text-gray-500 text-sm font-medium">총 회원수</h3>
            <div class="w-10 h-10 rounded-full bg-green-100 flex items-center justify-center text-green-600">
                <i class="ri-chat-smile-2-line ri-lg"></i>
            </div>
        </div>
        <span class="text-3xl font-bold text-gray-800">${totalUsers}</span>
        <p class="text-xs text-gray-500 mt-1">전체 가입 회원</p>
    </div>
    <!-- 총 승인 리뷰 수 -->
    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center justify-between mb-4">
            <h3 class="text-gray-500 text-sm font-medium">총 승인 리뷰 수</h3>
            <div class="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center text-blue-600">
                <i class="ri-user-community-line ri-lg"></i>
            </div>
        </div>
        <span class="text-3xl font-bold text-gray-800">${totalApprovedReviews}</span>
        <p class="text-xs text-gray-500 mt-1">승인 완료된 리뷰</p>
    </div>
    <!-- 답변 대기 문의 -->
    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center justify-between mb-4">
            <h3 class="text-gray-500 text-sm font-medium">답변 대기 문의</h3>
            <div class="w-10 h-10 rounded-full bg-red-100 flex items-center justify-center text-red-600">
                <i class="ri-alarm-warning-line ri-lg"></i>
            </div>
        </div>
        <span class="text-3xl font-bold text-gray-800">${openInquiries}</span>
        <p class="text-xs text-gray-500 mt-1">미답변 문의 건수</p>
    </div>
</div>


<!-- 차트 섹션 -->
<div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
    <!-- 여행지 카테고리별 조회수 (도넛 차트) -->
    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center justify-between mb-4">
            <h3 class="text-gray-700 font-medium">여행지 카테고리별 조회수</h3>
        </div>
        <div class="h-72 md:h-80 flex justify-center items-center"> 
            <canvas id="categoryViewChart"></canvas>
        </div>
    </div>

    <!-- 월별 총 방문자 추이 (라인 차트) - 일단 비워둠 -->
    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center justify-between mb-4">
            <h3 class="text-gray-700 font-medium">월별 총 방문자 추이</h3>
        </div>
        <div class="h-72 md:h-80 flex justify-center items-center text-gray-400">
            <canvas id="monthlyVisitorsChart"></canvas>
        </div>
    </div>
</div>

<!-- 사용자 로그인 경로 (막대 차트) 섹션 -->
<div class="bg-white rounded-lg shadow p-6 mb-6">
    <div class="flex items-center justify-between mb-4">
        <h3 class="text-gray-700 font-medium">사용자 로그인 경로</h3>
    </div>
    <div class="h-72 md:h-80"> 
        <canvas id="userOriginChart"></canvas>
    </div>
</div>



<script>
    document.addEventListener('DOMContentLoaded', function() {


     // --- Controller에서 전달된 JSON 데이터를 안전하게 가져오기 ---
const rawCategoryViewDataJson = '<c:out value="${categoryViewDataJson}" default="[]" escapeXml="false"/>';
const rawUserOriginDataJson = '<c:out value="${userOriginChartDataJson}" default="[]" escapeXml="false"/>';
const rawMonthlyVisitorDataJson = '<c:out value="${monthlyVisitorDataJson}" default="[]" escapeXml="false"/>';


let parsedCategoryData = [];
try {

    parsedCategoryData = JSON.parse(rawCategoryViewDataJson); 
    if (!Array.isArray(parsedCategoryData)) {
        console.warn("Parsed category data is not an array. Raw data:", rawCategoryViewDataJson);
        parsedCategoryData = [];
    }
} catch (e) {
    console.error("Error parsing category view data:", e, "Raw data for category:", rawCategoryViewDataJson);
    parsedCategoryData = [];
}

let parsedUserOriginData = [];
try {
    parsedUserOriginData = JSON.parse(rawUserOriginDataJson);
    if (!Array.isArray(parsedUserOriginData)) {
        console.warn("Parsed user origin data is not an array. Raw data:", rawUserOriginDataJson);
        parsedUserOriginData = [];
    }
} catch (e) {
    console.error("Error parsing user origin data:", e, "Raw data for user origin:", rawUserOriginDataJson);
    parsedUserOriginData = [];
}
        // 랜덤 색상 생성 함수 (데이터에 color 속성이 없을 경우 사용)
        function getRandomColor() {
            const r = Math.floor(Math.random() * 200); // 너무 밝은 색 피하기 위해 0-199
            const g = Math.floor(Math.random() * 200);
            const b = Math.floor(Math.random() * 200);
            return `rgba(${r}, ${g}, ${b}, 0.7)`; // 약간의 투명도 적용
        }
        
        
        let parsedMonthlyVisitorData = []; 
        try {
            parsedMonthlyVisitorData = JSON.parse(rawMonthlyVisitorDataJson);
            if (!parsedMonthlyVisitorData.labels || !Array.isArray(parsedMonthlyVisitorData.labels) ||
                !parsedMonthlyVisitorData.data || !Array.isArray(parsedMonthlyVisitorData.data)) {
                console.warn("Parsed monthly visitor data is not in expected format. Raw data:", rawMonthlyVisitorDataJson);
                parsedMonthlyVisitorData = []; 
            }
        } catch (e) {
            console.error("Error parsing monthly visitor data:", e, "Raw data for monthly visitor:", rawMonthlyVisitorDataJson);
            parsedMonthlyVisitorData = [];
        }


        // --- "여행지 카테고리별 조회수" 도넛 차트 ---
        const categoryViewCtx = document.getElementById('categoryViewChart');
        if (categoryViewCtx) { 
            if (parsedCategoryData && parsedCategoryData.length > 0) {
                const categoryLabels = parsedCategoryData.map(item => item.label || 'N/A');
                const categoryDataValues = parsedCategoryData.map(item => Number(item.value) || 0); // 숫자로 변환, 아니면 0
                const categoryBackgroundColors = parsedCategoryData.map(item => item.color || getRandomColor());
                const categoryBorderColors = categoryBackgroundColors.map(color => color ? color.replace(/0\.[0-9]+(?=\))/, '1') : '#cccccc'); // 투명도를 1로 또는 기본 테두리색

                new Chart(categoryViewCtx, {
                    type: 'doughnut',
                    data: {
                        labels: categoryLabels,
                        datasets: [{
                            label: '조회수',
                            data: categoryDataValues,
                            backgroundColor: categoryBackgroundColors,
                            borderColor: categoryBorderColors,
                            borderWidth: 1,
                            hoverOffset: 4
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false, // 컨테이너 높이에 맞추기 위함
                        plugins: {
                            legend: {
                                position: 'right', // 범례 위치
                                labels: {
                                    boxWidth: 12, // 범례 색상 상자 너비
                                    font: { size: 10 }
                                }
                            },
                            title: { display: false }, // 차트 제목은 HTML h3로 이미 있음
                            tooltip: {
                                callbacks: {
                                    label: function(context) {
                                        let label = context.label || '';
                                        if (label) { label += ': '; }
                                        if (context.parsed !== null) {
                                            label += context.parsed.toLocaleString() + ' 건';
                                        }
                                        return label;
                                    }
                                }
                            }
                        }
                    }
                });
            } else { // 데이터가 없거나 파싱 실패 시 Canvas에 메시지 표시
                 const ctx = categoryViewCtx.getContext('2d');
                 ctx.textAlign = 'center';
                 ctx.font = '14px Arial';
                 ctx.fillStyle = '#aaaaaa';
                 ctx.fillText('카테고리별 조회수 데이터가 없습니다.', categoryViewCtx.width / 2, categoryViewCtx.height / 2);
                 console.warn("No data to display for categoryViewChart.");
            }
        } else {
            console.warn("Canvas element with ID 'categoryViewChart' not found.");
        }


        // --- "사용자 로그인 경로" 막대 차트 ---
        const userOriginCtx = document.getElementById('userOriginChart');
        if (userOriginCtx) { // canvas 요소가 존재하는지 확인
            if (parsedUserOriginData && parsedUserOriginData.length > 0) {
                const originLabels = parsedUserOriginData.map(item => item.label || 'N/A');
                const originDataValues = parsedUserOriginData.map(item => Number(item.value) || 0);
                const originBackgroundColors = parsedUserOriginData.map(item => item.color || getRandomColor());
                const originBorderColors = originBackgroundColors.map(color => color ? color.replace(/0\.[0-9]+(?=\))/, '1') : '#cccccc');

                new Chart(userOriginCtx, {
                    type: 'bar',
                    data: {
                        labels: originLabels,
                        datasets: [{
                            label: '사용자 수',
                            data: originDataValues,
                            backgroundColor: originBackgroundColors,
                            borderColor: originBorderColors,
                            borderWidth: 1
                        }]
                    },
                    options: {
                        indexAxis: 'y', // 수평 막대 차트
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            x: {
                                beginAtZero: true,
                                ticks: {
                                    precision: 0 // x축 눈금 정수만 표시
                                }
                            }
                        },
                        plugins: {
                            legend: { display: false }, // 단일 데이터셋이므로 범례 숨김
                            title: { display: false },
                            tooltip: {
                                callbacks: {
                                    label: function(context) {
                                        let label = context.dataset.label || '';
                                        if (label) { label += ': '; }
                                        if (context.parsed.x !== null) { // 수평 막대이므로 x값
                                            label += context.parsed.x.toLocaleString() + ' 명';
                                        }
                                        return label;
                                    }
                                }
                            }
                        }
                    }
                });
            } else { // 데이터가 없거나 파싱 실패 시 Canvas에 메시지 표시
                const ctx = userOriginCtx.getContext('2d');
                ctx.textAlign = 'center';
                ctx.font = '14px Arial';
                ctx.fillStyle = '#aaaaaa';
                ctx.fillText('사용자 유입 경로 데이터가 없습니다.', userOriginCtx.width / 2, userOriginCtx.height / 2);
                console.warn("No data to display for userOriginChart.");
            }
        } else {
            console.warn("Canvas element with ID 'userOriginChart' not found.");
        }

        // "월별 총 방문자 추이" 
        
        const monthlyVisitorsCtx = document.getElementById('monthlyVisitorsChart');
        if (monthlyVisitorsCtx) {
            if (parsedMonthlyVisitorData && parsedMonthlyVisitorData.labels && parsedMonthlyVisitorData.labels.length > 0) {
                new Chart(monthlyVisitorsCtx, {
                    type: 'line',
                    data: {
                        labels: parsedMonthlyVisitorData.labels, // Controller에서 생성한 월별 레이블
                        datasets: [{
                            label: '월별 방문자 수', // 차트 범례에 표시될 이름
                            data: parsedMonthlyVisitorData.data,  // Controller에서 생성한 월별 방문자 수 데이터
                            borderColor: 'rgb(75, 192, 192)',    // 라인 색상 (예: 청록색)
                            backgroundColor: 'rgba(75, 192, 192, 0.2)', // 라인 아래 영역 색상 (선택적)
                            tension: 0.1, // 라인 곡률 (0이면 직선, 0.1~0.4 정도면 부드러운 곡선)
                            fill: false // 라인 아래 영역 채우기 여부 (true로 하면 채워짐)
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            y: {
                                beginAtZero: true,
                                ticks: {
                                    precision: 0 
                                }
                            }
                        },
                        plugins: {
                            legend: {
                                display: true, 
                                position: 'top',
                            },
                            title: {
                                display: false
                            },
                            tooltip: {
                                 callbacks: {
                                     label: function(context) {
                                         let label = context.dataset.label || '';
                                         if (label) {
                                             label += ': ';
                                         }
                                         if (context.parsed.y !== null) {
                                             label += context.parsed.y.toLocaleString() + ' 명';
                                         }
                                         return label;
                                     }
                                 }
                             }
                        }
                    }
                });
            } else {
                const ctx = monthlyVisitorsCtx.getContext('2d');
                ctx.textAlign = 'center';
                ctx.font = '14px Arial';
                ctx.fillStyle = '#aaaaaa';
                ctx.fillText('월별 방문자 추이 데이터가 없습니다.', monthlyVisitorsCtx.width / 2, monthlyVisitorsCtx.height / 2);
                console.warn("No data to display for monthlyVisitorsChart.");
            }
        } else {
            console.warn("Canvas element with ID 'monthlyVisitorsChart' not found.");
        }

    });
</script>
document.addEventListener('DOMContentLoaded', function () {
  console.log("✅ mainpage.js 로딩됨");
  console.log(pageContextPath);

  // 🔧 추천 여행지 불러오는 함수 정의
// mainpage.js

function loadRandomDestinations() {
    const url = `${pageContextPath}/randomDestinations?ts=${Date.now()}`;
    console.log('▶ 추천 여행지 호출 URL:', url);

    fetch(url)
      .then(res => {
        console.log('▶ fetch 응답 상태:', res.status);
        return res.json();
      })
      .then(data => {
        console.log('▶ 추천 여행지 리스트:', data);

        const container = document.getElementById('topDestinations');
        container.innerHTML = '';

data.forEach(dest => {
  const id = dest.dest_id;
  const imgHTML = dest.repr_img_url
    ? `<img src="${dest.repr_img_url}" alt="${dest.dest_name}" class="w-full h-full object-cover object-top">`
    : `<div class="skeleton-img"></div>`;

  container.insertAdjacentHTML('beforeend', `
    <div
      class="flex items-center gap-4 p-2 cursor-pointer hover:bg-gray-100 transition border-b border-gray-200 last:border-b-0"
      data-dest-id="${id}"
    >
      <div class="w-16 h-16 rounded-lg overflow-hidden flex-shrink-0">
        ${imgHTML}
      </div>
      <div class="flex-grow">
        <h4 class="font-medium text-gray-900">${dest.dest_name}</h4>
        <p class="text-sm text-gray-500">${dest.full_address || '주소 정보 없음'}</p>
      </div>
    </div>
  `);
});
        // 클릭 핸들러 등록
        container.querySelectorAll('[data-dest-id]').forEach(card => {
          card.addEventListener('click', function () {
            const id = this.getAttribute('data-dest-id');
            console.log('🔗 카드 클릭, destId=', id);
            const targetUrl = `${pageContextPath}/destinationdetail?dest_id=${id}`;
            console.log('▶ Redirect to', targetUrl);
            window.location.href = targetUrl;
          });
        });
      })
      .catch(err => console.error('🔥 추천 여행지 불러오기 실패:', err));
  }

// 페이지 로드 시 실행

  // ✅ 초기 실행 시 추천 여행지 불러오기
  loadRandomDestinations();

  // ✅ 버튼 클릭 시 새로고침
  document.getElementById('refreshDestBtn')?.addEventListener('click', () => {
    console.log("🔁 새로고침 버튼 클릭됨");
    localStorage.removeItem('todayDestinations');
    loadRandomDestinations(); // 새로 불러오기
  });

  
  // ------------------------------------------------------------------
  // 날씨 정보 카드 슬라이더 (수동 넘김 기능)
  // ------------------------------------------------------------------
  
  
  
  
  
  const weatherWidgetContainer = document.querySelector('.weather-container');
  const weatherCards = weatherWidgetContainer ? weatherWidgetContainer.querySelectorAll('.weather-card') : [];
  const weatherPrevBtn = document.getElementById('weatherPrevBtn');
  const weatherNextBtn = document.getElementById('weatherNextBtn');

  if (weatherWidgetContainer && weatherCards.length > 0 && weatherPrevBtn && weatherNextBtn) {
    let currentWeatherPageIndex = 0;

    function getCardsPerPageForWeather() {
      if (window.innerWidth >= 1024) { // lg (1024px)
        return 4;
      } else if (window.innerWidth >= 640) { // sm (640px)
        return 2;
      }
      return 1;
    }

    function updateWeatherSliderDisplay() {
      const cardsPerPage = getCardsPerPageForWeather();
      const totalWeatherCards = weatherCards.length;
      // ⭐ totalWeatherPages는 여기서 한 번만 올바르게 계산되면 됩니다.
      const totalWeatherPages = Math.ceil(totalWeatherCards / cardsPerPage);

      // 디버깅 로그 추가
      console.log(`Update Slider: currentPage=${currentWeatherPageIndex}, cardsPerPage=${cardsPerPage}, totalCards=${totalWeatherCards}, totalPages=${totalWeatherPages}`);

      weatherCards.forEach((card, index) => {
        const pageIndexOfCard = Math.floor(index / cardsPerPage);
        if (pageIndexOfCard === currentWeatherPageIndex) {
          card.classList.remove('hidden');
        } else {
          card.classList.add('hidden');
        }
      });

      if (totalWeatherPages <= 1) {
        weatherPrevBtn.style.display = 'none';
        weatherNextBtn.style.display = 'none';
      } else {
        weatherPrevBtn.style.display = 'flex';
        weatherNextBtn.style.display = 'flex';

        weatherPrevBtn.disabled = (currentWeatherPageIndex === 0);
        weatherNextBtn.disabled = (currentWeatherPageIndex >= totalWeatherPages - 1); // ⭐ 이 조건이 핵심

        weatherPrevBtn.classList.toggle('opacity-50', weatherPrevBtn.disabled);
        weatherPrevBtn.classList.toggle('cursor-not-allowed', weatherPrevBtn.disabled);
        weatherNextBtn.classList.toggle('opacity-50', weatherNextBtn.disabled);
        weatherNextBtn.classList.toggle('cursor-not-allowed', weatherNextBtn.disabled);
      }
    }

    weatherPrevBtn.addEventListener('click', () => {
      if (currentWeatherPageIndex > 0) {
        currentWeatherPageIndex--;
        updateWeatherSliderDisplay();
      }
    });

    weatherNextBtn.addEventListener('click', () => {
      // ⭐ Next 버튼 클릭 시, totalWeatherPages를 현재 cardsPerPage 기준으로 다시 계산하여 비교
      const cardsPerPage = getCardsPerPageForWeather();
      const totalWeatherCards = weatherCards.length;
      const totalWeatherPages = Math.ceil(totalWeatherCards / cardsPerPage);

      if (currentWeatherPageIndex < totalWeatherPages - 1) {
        currentWeatherPageIndex++;
        updateWeatherSliderDisplay();
      } else {
       
      
      }
    });

    window.addEventListener('resize', () => {
      const cardsPerPage = getCardsPerPageForWeather();
      const totalWeatherCards = weatherCards.length;
      const totalWeatherPages = Math.ceil(totalWeatherCards / cardsPerPage);
      // 창 크기 변경 시 현재 페이지 인덱스가 유효한 범위 내에 있도록 조정
      if (currentWeatherPageIndex >= totalWeatherPages) {
        currentWeatherPageIndex = Math.max(0, totalWeatherPages - 1);
      }
      updateWeatherSliderDisplay();
    });

    if (weatherCards.length > 0) {
      updateWeatherSliderDisplay();
    } else {
      weatherPrevBtn.style.display = 'none';
      weatherNextBtn.style.display = 'none';
    }

  } else {
    console.warn("날씨 슬라이더 관련 DOM 요소(weather-container, weather-card, 버튼) 중 일부를 찾을 수 없습니다.");
    if (weatherPrevBtn) weatherPrevBtn.style.display = 'none';
    if (weatherNextBtn) weatherNextBtn.style.display = 'none';
  }

 // ✅ 커스텀 셀렉트 박스 동작
  const selectButtons = document.querySelectorAll('.custom-select button');
  const selectOptions = document.querySelectorAll('.custom-select-options div');

  selectButtons.forEach(button => {
    button.addEventListener('click', function () {
      const parent = this.closest('.custom-select');
      parent.classList.toggle('active');
    });
  });

  selectOptions.forEach(option => {
    option.addEventListener('click', function () {
      const parent = this.closest('.custom-select');
      const button = parent.querySelector('button span');
      button.textContent = this.textContent;
      parent.classList.remove('active');
    });
  });

  // ✅ 셀렉트 외부 클릭 시 닫기
  document.addEventListener('click', function (event) {
    document.querySelectorAll('.custom-select.active').forEach(select => {
      if (!select.contains(event.target)) select.classList.remove('active');
    });
  });

  // ✅ 테마별 추천 여행지 슬라이드 버튼 - 카드 1개씩 정확하게 이동
  const slider = document.querySelector('.theme-slider');
  const btnPrev = document.querySelector('.btn-prev');
  const btnNext = document.querySelector('.btn-next');

  if (slider && btnPrev && btnNext) {
    setTimeout(() => {
      const cards = slider.querySelectorAll('.flex-shrink-0'); // 정확한 카드 선택
      if (cards.length === 0) return;
      const cardWidth = cards[0].offsetWidth + 24; // 카드 너비 + margin gap (Tailwind 기준)

      btnPrev.addEventListener('click', () => {
        console.log("⬅️ Prev 버튼 클릭됨");
        slider.scrollBy({ left: -cardWidth, behavior: 'smooth' });
      });

      btnNext.addEventListener('click', () => {
        console.log("➡️ Next 버튼 클릭됨");
        slider.scrollBy({ left: cardWidth, behavior: 'smooth' });
      });
    }, 300); // 렌더링 완료 후 실행 보장
  }

  // ✅ 배경 이미지 슬라이드 전환
  const slideImages = document.querySelectorAll('.slide-img');
  let currentSlide = 0;

  if (slideImages.length > 0) {
    slideImages[currentSlide].classList.add('active');
    setInterval(() => {
      slideImages[currentSlide].classList.remove('active');
      currentSlide = (currentSlide + 1) % slideImages.length;
      slideImages[currentSlide].classList.add('active');
    }, 8000);
  }

  // ✅ 방문자 수 증가 및 조회  
  if (contextPath !== '') {
    $.ajax({
      url: contextPath + '/visit/increase',
      type: 'GET',
      success: function(response) {
        console.log('방문자 수 증가 완료:', response);
      },
      error: function(xhr, status, error) {
        console.log('방문자 수 증가 실패:', error);
      }
    });

    $.ajax({
      url: contextPath + '/visit/today',
      type: 'GET',
      success: function(count) {
        $('#visitCount').text('오늘 방문자 수: ' + count);
      },
      error: function(xhr, status, error) {
        console.log('오늘 방문자 수 조회 실패:', error);
        $('#visitCount').text('오늘 방문자 수: 조회 실패');
      }
    });
  } else {
    console.warn('contextPath가 정의되지 않았습니다. JSP에서 pageContextPath 변수를 선언하세요.');
  }

});

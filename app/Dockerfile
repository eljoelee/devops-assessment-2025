# Multi-stage build를 활용한 최적화된 Dockerfile
FROM python:3.11-slim as builder
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# .pyc 파일 미리 생성 
# 소스코드를 바이트코드로 컴파일하는 과정 생략
ENV UV_COMPILE_BYTECODE=1 

# .venv 내부에 uv가 설치한 라이브러리 복사
# 빌더 단계에서 링크 파일 복사 시 링크가 가리키는 원본 파일이 없는 문제 방지
ENV UV_LINK_MODE=copy

WORKDIR /app

COPY pyproject.toml uv.lock ./

# 호스트 머신의 디렉토리에 캐싱
# frozen: 라이브러리 버전 고정
# no-install-project: 오직 의존성 패키지만 설치
# no-dev: 개발 의존성 설치 생략
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-install-project --no-dev

COPY main.py ./

# 의존성 파일 복사
# COPY requirements.txt .

# 의존성 설치 (wheel 빌드)
# RUN pip install --no-cache-dir --user -r requirements.txt

# 실행 단계
FROM python:3.11-slim

# 보안을 위한 non-root 유저 생성
RUN groupadd -r appuser && useradd -r -g appuser -u 1000 appuser

WORKDIR /app

# builder 단계에서 설치한 패키지 복사
# COPY --from=builder --chown=appuser:appuser /root/.local /home/appuser/.local
COPY --from=builder --chown=appuser:appuser /app /app

# uvicorn 실행 시, uv run 생략
ENV PATH="/app/.venv/bin:$PATH"

# 애플리케이션 코드 복사
# COPY --chown=appuser:appuser main.py .

# PATH 환경변수에 pip 설치 경로 추가
# ENV PATH=/home/appuser/.local/bin:$PATH

# 애플리케이션 포트
EXPOSE 8000

# non-root 유저로 전환
USER appuser

# 헬스체크 설정 (curl 대신 python 사용)
# 소켓 반환 구문 추가
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health').close()" || exit 1

# 애플리케이션 실행
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

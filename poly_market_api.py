#!/usr/bin/env python3
"""
Poly Market API 연동 테스트 코드
Week 1 - Server Environment Setup & API Integration Test
"""

import os
import requests
from typing import Optional, Dict, Any
from dotenv import load_dotenv

# Load environment variables
load_dotenv()


class PolyMarketAPI:
    """Poly Market API 클라이언트"""
    
    def __init__(self, api_key: Optional[str] = None, base_url: str = "https://api.poly.market"):
        self.api_key = api_key or os.getenv("POLY_MARKET_API_KEY")
        self.base_url = base_url.rstrip("/")
        self.headers = {
            "Content-Type": "application/json",
        }
        if self.api_key:
            self.headers["Authorization"] = f"Bearer {self.api_key}"
    
    def _request(self, method: str, endpoint: str, params: Optional[Dict] = None, 
                 data: Optional[Dict] = None) -> Dict[str, Any]:
        """API 요청을 처리하는 기본 메서드"""
        url = f"{self.base_url}{endpoint}"
        
        try:
            response = requests.request(
                method=method,
                url=url,
                headers=self.headers,
                params=params,
                json=data,
                timeout=30
            )
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"API Request Error: {e}")
            raise
    
    def get_markets(self, limit: int = 100, offset: int = 0) -> Dict[str, Any]:
        """마켓 목록 조회"""
        return self._request("GET", "/v1/markets", params={"limit": limit, "offset": offset})
    
    def get_market_by_id(self, market_id: str) -> Dict[str, Any]:
        """특정 마켓 정보 조회"""
        return self._request("GET", f"/v1/markets/{market_id}")
    
    def get_orderbook(self, market_id: str) -> Dict[str, Any]:
        """마켓 주문서 조회"""
        return self._request("GET", f"/v1/markets/{market_id}/orderbook")
    
    def get_trades(self, market_id: str, limit: int = 100, offset: int = 0) -> Dict[str, Any]:
        """마켓 거래 내역 조회"""
        return self._request("GET", f"/v1/markets/{market_id}/trades", 
                           params={"limit": limit, "offset": offset})
    
    def get_user_positions(self, wallet_address: str) -> Dict[str, Any]:
        """지정된 지갑의 포지션 조회"""
        return self._request("GET", "/v1/positions", params={"wallet": wallet_address})
    
    def place_order(self, market_id: str, side: str, price: float, quantity: float,
                   order_type: str = "limit") -> Dict[str, Any]:
        """주문-placement"""
        data = {
            "marketId": market_id,
            "side": side,  # "buy" or "sell"
            "price": price,
            "quantity": quantity,
            "orderType": order_type
        }
        return self._request("POST", "/v1/orders", data=data)
    
    def cancel_order(self, order_id: str) -> Dict[str, Any]:
        """주문 취소"""
        return self._request("DELETE", f"/v1/orders/{order_id}")


def test_api_connection() -> bool:
    """API 연결 테스트"""
    try:
        api = PolyMarketAPI()
        # Public endpoint 테스트 (API 키 없이)
        response = api.get_markets(limit=1)
        print(f"✓ API 연결 성공. 샘플 마켓: {response.get('markets', [{}])[0].get('id', 'N/A')}")
        return True
    except Exception as e:
        print(f"✗ API 연결 실패: {e}")
        return False


def test_full_workflow():
    """전체 워크플로우 테스트"""
    print("\n=== Poly Market API 테스트 ===\n")
    
    # 1. 연결 테스트
    print("1. API 연결 테스트...")
    if not test_api_connection():
        print(" 연결 실패 - API 키를 확인하세요.")
        return False
    
    # 2. 마켓 목록 조회
    print("\n2. 마켓 목록 조회...")
    try:
        api = PolyMarketAPI()
        markets = api.get_markets(limit=5)
        print(f" ✓ 조회된 마켓 수: {len(markets.get('markets', []))}")
        for market in markets.get('markets', [])[:3]:
            print(f"   - {market.get('id')}: {market.get('question', 'N/A')}")
    except Exception as e:
        print(f" ✗ 마켓 목록 조회 실패: {e}")
    
    # 3. 특정 마켓 정보 조회 (첫 번째 마켓 ID 사용)
    if markets.get('markets'):
        market_id = markets['markets'][0]['id']
        print(f"\n3. 마켓 정보 조회: {market_id}...")
        try:
            market_info = api.get_market_by_id(market_id)
            print(f" ✓ 마켓 정보 조회 성공")
            print(f"   - 질문: {market_info.get('question', 'N/A')}")
            print(f"   - 현재 가격: {market_info.get('currentPrice', 'N/A')}")
        except Exception as e:
            print(f" ✗ 마켓 정보 조회 실패: {e}")
    
    # 4. 주문서 조회
    if markets.get('markets'):
        print(f"\n4. 주문서 조회...")
        try:
            orderbook = api.get_orderbook(market_id)
            print(f" ✓ 주문서 조회 성공")
            bids = orderbook.get('bids', [])
            asks = orderbook.get('asks', [])
            print(f"   - 매수 호가 수: {len(bids)}")
            print(f"   - 매도 호가 수: {len(asks)}")
        except Exception as e:
            print(f" ✗ 주문서 조회 실패: {e}")
    
    print("\n=== 테스트 완료 ===\n")
    return True


if __name__ == "__main__":
    print("Poly Market API 연동 테스트를 시작합니다.\n")
    test_full_workflow()

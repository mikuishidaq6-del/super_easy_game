"""
ゲームロジック計算モジュール

specifications/feature-logic/ に基づいて実装された
レベルアップ必要経験値およびコイン取得量の計算関数を提供する。
"""

import math


# ---------------------------------------------------------------------------
# コイン取得計算 (CoinGainWalk.md)
# ---------------------------------------------------------------------------

def calculate_coin_normal(steps: int | float) -> float:
    """通常時のコイン獲得量を計算する（ロジスティック関数）。

    Coin(x) = L / (1 + e^(-k(x - x0)))

    Args:
        steps: プレイヤーの歩数

    Returns:
        獲得コイン数（0 〜 L の範囲）
    """
    L = 20      # コイン獲得の上限
    k = 0.01    # 成長の速さを調整するパラメータ
    x0 = 500    # コイン獲得の成長が最も速くなる歩数（目標歩数）

    return L / (1 + math.exp(-k * (steps - x0)))


def calculate_coin_poor_health(steps: int | float) -> float:
    """体調不良時のコイン獲得量を計算する（対数関数）。

    Coin(x) = a * ln(x + 1)

    Args:
        steps: プレイヤーの歩数

    Returns:
        獲得コイン数
    """
    a = 2.8     # コイン獲得のスケーリングパラメータ

    return a * math.log(steps + 1)


def calculate_coin_rehabilitation(steps: int | float) -> float:
    """リハビリ用のコイン獲得量を計算する（ガウス関数）。

    閾値以上歩くと獲得可能コインが減る関数。

    Coin(x) = L * exp(-(x - μ)^2 / (2 * σ^2))

    Args:
        steps: プレイヤーの歩数

    Returns:
        獲得コイン数（0 〜 L の範囲）
    """
    L = 20      # コイン獲得の上限
    mu = 1200   # コイン獲得のピークとなる歩数
    sigma = 500  # コイン獲得の広がりを調整するパラメータ

    return L * math.exp(-((steps - mu) ** 2) / (2 * sigma ** 2))


# ---------------------------------------------------------------------------
# レベルアップ必要経験値計算 (levelUp-exp.md)
# ---------------------------------------------------------------------------

def calculate_required_exp(level: int, base_exp: int = 100) -> float:
    """指定レベルにレベルアップするために必要な経験値を計算する。

    Required EXP = L_0 * 1.05 ^ n

    Args:
        level:    現在のレベル（1 以上）。このレベルから次のレベルへの必要経験値を返す。
                  例: level=1 → レベル1からレベル2に必要な経験値を返す。
        base_exp: レベル1からレベル2に必要な経験値（L_0）。デフォルト 100。

    Returns:
        level から level+1 へのレベルアップに必要な経験値
    """
    if level < 1:
        raise ValueError("level は 1 以上でなければなりません")

    n = level - 1  # 現在のレベル - 1
    return base_exp * (1.05 ** n)

"""
calculations.py のユニットテスト
"""

import math
import unittest

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from calculations import (
    calculate_coin_normal,
    calculate_coin_poor_health,
    calculate_coin_rehabilitation,
    calculate_required_exp,
)


class TestCalculateCoinNormal(unittest.TestCase):
    """通常時コイン獲得関数のテスト（ロジスティック関数）"""

    def test_output_range_is_between_0_and_L(self):
        """コイン獲得量は 0 〜 20 の範囲に収まる"""
        for steps in [0, 100, 500, 1000, 5000]:
            coin = calculate_coin_normal(steps)
            self.assertGreaterEqual(coin, 0)
            self.assertLessEqual(coin, 20)

    def test_midpoint_returns_half_of_L(self):
        """歩数が x0=500 のとき、獲得量は L/2=10 に等しい"""
        coin = calculate_coin_normal(500)
        self.assertAlmostEqual(coin, 10.0, places=5)

    def test_monotonically_increasing(self):
        """歩数が増えるほどコイン獲得量が増加する"""
        steps_list = [0, 200, 500, 800, 1000]
        coins = [calculate_coin_normal(s) for s in steps_list]
        for i in range(len(coins) - 1):
            self.assertLess(coins[i], coins[i + 1])

    def test_approaches_L_for_large_steps(self):
        """歩数が非常に多い場合、獲得量は上限 L=20 に近づく"""
        coin = calculate_coin_normal(10000)
        self.assertAlmostEqual(coin, 20.0, places=2)

    def test_zero_steps(self):
        """歩数 0 のときの計算が正常に行われる"""
        coin = calculate_coin_normal(0)
        expected = 20 / (1 + math.exp(-0.01 * (0 - 500)))
        self.assertAlmostEqual(coin, expected, places=10)


class TestCalculateCoinPoorHealth(unittest.TestCase):
    """体調不良時コイン獲得関数のテスト（対数関数）"""

    def test_zero_steps_returns_zero(self):
        """歩数 0 のとき、コイン獲得量は 0"""
        coin = calculate_coin_poor_health(0)
        self.assertAlmostEqual(coin, 0.0, places=10)

    def test_monotonically_increasing(self):
        """歩数が増えるほどコイン獲得量が増加する"""
        steps_list = [0, 100, 500, 1000, 5000]
        coins = [calculate_coin_poor_health(s) for s in steps_list]
        for i in range(len(coins) - 1):
            self.assertLess(coins[i], coins[i + 1])

    def test_known_value(self):
        """既知の値での計算結果を検証する"""
        # Coin(1) = 2.8 * ln(2)
        expected = 2.8 * math.log(2)
        self.assertAlmostEqual(calculate_coin_poor_health(1), expected, places=10)

    def test_output_positive_for_positive_steps(self):
        """正の歩数に対してコイン獲得量は正となる"""
        for steps in [1, 100, 1000]:
            self.assertGreater(calculate_coin_poor_health(steps), 0)


class TestCalculateCoinRehabilitation(unittest.TestCase):
    """リハビリ用コイン獲得関数のテスト（ガウス関数）"""

    def test_peak_at_mu(self):
        """歩数が μ=1200 のとき、コイン獲得量は上限 L=20 に等しい"""
        coin = calculate_coin_rehabilitation(1200)
        self.assertAlmostEqual(coin, 20.0, places=10)

    def test_output_range_is_between_0_and_L(self):
        """コイン獲得量は 0 〜 20 の範囲に収まる"""
        for steps in [0, 500, 1200, 2000, 5000]:
            coin = calculate_coin_rehabilitation(steps)
            self.assertGreaterEqual(coin, 0)
            self.assertLessEqual(coin, 20)

    def test_decreases_away_from_peak(self):
        """ピーク（μ=1200）から離れるにつれてコイン獲得量が減少する"""
        peak = calculate_coin_rehabilitation(1200)
        below_peak = calculate_coin_rehabilitation(700)
        above_peak = calculate_coin_rehabilitation(1700)
        self.assertGreater(peak, below_peak)
        self.assertGreater(peak, above_peak)

    def test_symmetry_around_peak(self):
        """ガウス関数はピーク周辺で対称的な形状をもつ"""
        delta = 300
        left = calculate_coin_rehabilitation(1200 - delta)
        right = calculate_coin_rehabilitation(1200 + delta)
        self.assertAlmostEqual(left, right, places=10)


class TestCalculateRequiredExp(unittest.TestCase):
    """レベルアップ必要経験値関数のテスト"""

    def test_level_1_requires_base_exp(self):
        """レベル1のとき、必要経験値は base_exp（100）に等しい"""
        self.assertAlmostEqual(calculate_required_exp(1), 100.0, places=10)

    def test_level_2_applies_one_growth(self):
        """レベル2のとき、必要経験値は 100 * 1.05^1"""
        expected = 100 * 1.05
        self.assertAlmostEqual(calculate_required_exp(2), expected, places=10)

    def test_level_10_applies_nine_growths(self):
        """レベル10のとき、必要経験値は 100 * 1.05^9"""
        expected = 100 * (1.05 ** 9)
        self.assertAlmostEqual(calculate_required_exp(10), expected, places=10)

    def test_custom_base_exp(self):
        """base_exp を変更した場合でも正しく計算される"""
        self.assertAlmostEqual(calculate_required_exp(1, base_exp=200), 200.0, places=10)
        expected = 200 * (1.05 ** 4)
        self.assertAlmostEqual(calculate_required_exp(5, base_exp=200), expected, places=10)

    def test_invalid_level_raises(self):
        """level が 1 未満の場合 ValueError が発生する"""
        with self.assertRaises(ValueError):
            calculate_required_exp(0)
        with self.assertRaises(ValueError):
            calculate_required_exp(-1)

    def test_exp_increases_with_level(self):
        """レベルが上がるほど必要経験値が増加する"""
        exps = [calculate_required_exp(lv) for lv in range(1, 11)]
        for i in range(len(exps) - 1):
            self.assertLess(exps[i], exps[i + 1])


if __name__ == "__main__":
    unittest.main()

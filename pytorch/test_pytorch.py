import unittest

from parameterized import parameterized

from integration_tests.dataproc_test_case import DataprocTestCase


class TonYTestCase(DataprocTestCase):
    COMPONENT = 'pytorch'
    INIT_ACTIONS = ['pytorch/pytorch.sh']

    @parameterized.expand(
        [
            ("STANDARD", "1.4"),
        ],
        testcase_func_name=DataprocTestCase.generate_verbose_test_name)
    def test_tony(self, configuration, dataproc_version):
        self.createCluster(configuration, self.INIT_ACTIONS, dataproc_version)

        # Verify PyTorch installation
        cmd = '''
            gcloud dataproc jobs submit hadoop --cluster={} \
                file:///opt/pytorch/examples/test_gpu.py
            '''.format(self.name)
        ret_code, stdout, stderr = self.run_command(cmd)
        self.assertEqual(
            ret_code, 0,
            "PyTorch unavailable.".format(
                "\nCommand:\n{}\nLast error:\n{}".format(cmd, stderr)))

        # Verify PyTorch can utilize GPUs
        cmd = '''
            gcloud dataproc jobs submit hadoop --cluster={} \
                file:///opt/pytorch/examples
            '''.format(self.name)
        ret_code, stdout, stderr = self.run_command(cmd)
        self.assertEqual(
            ret_code, 0,
            "GPUs unavailable.".format(
                "\nCommand:\n{}\nLast error:\n{}".format(cmd, stderr)))


if __name__ == '__main__':
    unittest.main()

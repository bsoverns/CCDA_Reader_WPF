using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.IO;
using System.Windows;
using System.Xml;
using System.Xml.Xsl;
using Microsoft.Win32;

namespace CCDA_Reader
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            XmlDocument ccdaDocument = new XmlDocument();
            //ccdaDocument.Load(@"D:\Desktop\MyCCDA\New\Document_XML\bradley_soverns_AmbulatorySummary1_alltime - Copy.xml");
            ccdaDocument.Load(ccdaFilePathTextBox.Text);

            // Load the XSLT stylesheet
            XslCompiledTransform xslt = new XslCompiledTransform();
            //xslt.Load(@"D:\Desktop\MyCCDA\New\Document_XML\cda_ngmu2.xsl"); // path to your XSLT stylesheet
            xslt.Load(xsltFilePathTextBox.Text); // path to your XSLT stylesheet

            // Transform the CCDA document using the XSLT stylesheet
            using (StringWriter sw = new StringWriter())
            using (XmlWriter xwo = XmlWriter.Create(sw, xslt.OutputSettings)) // use OutputSettings of xsl, so it can be output as HTML
            {
                xslt.Transform(ccdaDocument, xwo);
                //TextBox.Text = sw.ToString();
                webBrowser.NavigateToString(sw.ToString());
            }
        }

        private void SelectCCDA_Click(object sender, RoutedEventArgs e)
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();
            openFileDialog.Filter = "XML Files (*.xml)|*.xml|All Files (*.*)|*.*";
            if (openFileDialog.ShowDialog() == true)
            {
                ccdaFilePathTextBox.Text = openFileDialog.FileName;
            }
        }

        private void SelectXSLT_Click(object sender, RoutedEventArgs e)
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();
            openFileDialog.Filter = "XSLT Files (*.xsl)|*.xsl|All Files (*.*)|*.*";
            if (openFileDialog.ShowDialog() == true)
            {
                xsltFilePathTextBox.Text = openFileDialog.FileName;
            }
        }
    }
}

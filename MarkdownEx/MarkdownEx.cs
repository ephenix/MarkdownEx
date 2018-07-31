using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Management.Automation;
using Markdig;

namespace MarkdownEx
{
    [Cmdlet(VerbsData.ConvertFrom, "Markdown")]
    public class MarkdownEx : PSCmdlet
    {
        [Parameter(
            Position = 0,
            Mandatory = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true
        )]
        public string MarkdownContent
        {
            get { return _markdownContent; }
            set { _markdownContent = value; }
        }
        private string _markdownContent = string.Empty;
        
        protected override void ProcessRecord()
        {
            if (MarkdownContent != null && MarkdownContent.Length > 0)
            {
                var pipeline = new MarkdownPipelineBuilder().UseAdvancedExtensions().Build();
                WriteObject(Markdown.ToHtml(MarkdownContent, pipeline));
            }
        }
    }
}
chess_to_csv=function(txt_url, export_path_name){
  
  lines= readLines(txt_url)
  lines
    
  lines=lines[-c(1,2,3,4)]
  
  
  if (length(lines)%%3 == 0){
    multiples_of_3=seq(3, length(lines),by=3)
    lines=lines[-c(multiples_of_3)]
  }
  
  lines
  
  line_one=c()
  line_two=c()
  id=1
  
  for(line in lines){
    if(id%%2==0){
      line_two=c(line_two,line)
    }else {
      line_one=c(line_one,line)
    }
    id=id+1
  }
  line_one
  line_two
  
  split_data_one=lapply(line_one, function(x) strsplit(x, "\\|"))
  split_data_two=lapply(line_two, function(x) strsplit(x, "\\|"))  
  split_data_one_mat=do.call(rbind, lapply(split_data_one, function(x) unlist(x[[1]])))
  df_one=as.data.frame(split_data_one_mat, stringsAsFactors = FALSE)
  split_data_two_mat=do.call(rbind, lapply(split_data_two, function(x) unlist(x[[1]])))
  df_two=as.data.frame(split_data_two_mat, stringsAsFactors = FALSE)
  
  col_names_1=c('player_id','name','total_pts','rnd_1_comb','rnd_2_comb','rnd_3_comb','rnd_4_comb','rnd_5_comb','rnd_6_comb','rnd_7_comb')
  colnames(df_one)=col_names_1
  col_names_2=c('state','comb_rank','idk','col_rnd_1','col_rnd_2','col_rnd_3','col_rnd_4','col_rnd_5','col_rnd_6','col_rnd_7')
  colnames(df_two)=col_names_2
  
  head(df_one)
  head(df_two)

  
  df_one_to_split=c('rnd_1_comb','rnd_2_comb','rnd_3_comb','rnd_4_comb','rnd_5_comb','rnd_6_comb','rnd_7_comb')
    
  for (col in df_one_to_split){
    df_one[[col]]=as.numeric(gsub("[^0-9]","",df_one[[col]]))
  }
  
  head(df_one)
  
  col_names_1=c('player_id','name','total_pts','rnd_1_op','rnd_2_op','rnd_3_op','rnd_4_op','rnd_5_op','rnd_6_op','rnd_7_op')
  colnames(df_one)=col_names_1
    
  library(stringr)
  
  df_two$comb_rank=str_extract(df_two$comb_rank, "(?<=R: )\\d+")
  df_two$comb_rank=as.numeric(df_two$comb_rank)
  col_names_2=c('state','pre_rank','idk','col_rnd_1','col_rnd_2','col_rnd_3','col_rnd_4','col_rnd_5','col_rnd_6','col_rnd_7')
  colnames(df_two)=col_names_2
  head(df_two)
  
  df_two$col_rnd_1=NULL
  df_two$col_rnd_2=NULL
  df_two$col_rnd_3=NULL
  df_two$col_rnd_4=NULL
  df_two$col_rnd_5=NULL
  df_two$col_rnd_6=NULL
  df_two$col_rnd_7=NULL
  df_two$idk=NULL
  head(df_two)
  
  
  chess_df=cbind(df_one,df_two)
  chess_df$player_id=as.integer(chess_df$player_id)
  head(chess_df)
  
  chess_df$avg_op_pre_rank = NA
  
  for (i in 1:nrow(chess_df)) {
    
    
    op_ids = unlist(chess_df[i, grep("rnd_\\d+_op", names(chess_df))])
    
    op_ids=as.integer(op_ids)
        
    op_ids=na.omit(op_ids)
        
    op_ranks = chess_df[chess_df$player_id %in% op_ids, "pre_rank"]
        
    chess_df$avg_op_pre_rank[i] = mean(op_ranks, na.rm = TRUE)
  }
  
  head(chess_df)
    
  to_be_exported_list=list(Player_Name=chess_df$name,
                           Player_State=chess_df$state,
                           Total_Points=chess_df$total_pts,
                           Player_Pre_Rating=chess_df$pre_rank,
                           Average_Opponent_Pre_Rating=chess_df$avg_op_pre_rank)
  to_be_exported_df=as.data.frame(to_be_exported_list)
  
  head(to_be_exported_df)
  
  write.csv(to_be_exported_df,export_path_name, row.names=FALSE)
  
}